extends CharacterBody2D

# Add a signal to tell the map when to start moving
signal chase_started 
@export var warning_line_scene: PackedScene # Drag WarningLine.tscn here!
var is_preparing_attack := false # Tracks if she is currently locked in an attack
@export var horizontal_speed := 50.0 

@onready var left_point: Marker2D = $LeftWingPoint
@onready var right_point: Marker2D = $RightWingPoint
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- Attack Variables ---
@export var blood_spear_scene: PackedScene # Drag your spear.tscn here in the Inspector!
@export var fire_rate := 1.5               # How many seconds between shots
var shoot_timer := 0.0

var player: CharacterBody2D
var is_active := false 

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	
	# 1. Hide her completely off the top of the screen to start
	global_position.y = -200 
	animated_sprite.play("flying")
	
	# 2. Trigger the entrance
	cinematic_entrance()

func cinematic_entrance() -> void:
	# Create a tween to make her swoop down smoothly
	var tween = create_tween()
	
	# Move her to Y = 120 (adjust this number based on where you want her to hover) over 2 seconds
	tween.tween_property(self, "global_position:y", 0.0, 2.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		
	# When she finishes swooping in...
	tween.finished.connect(func():
		# Optional: Play a roar or attack animation to intimidate the player!
		animated_sprite.play("attack")
		
		# Wait 1 second for dramatic effect
		await get_tree().create_timer(0.00005).timeout 
		
		# Start the actual fight!
		start_fight()
	)

func start_fight() -> void:
	is_active = true
	animated_sprite.play("flying")
	# Tell the ChaseManager that the boss has arrived!
	emit_signal("chase_started")

func _physics_process(delta: float) -> void:
	if not is_active or player == null:
		return
		
# --- X-Axis Tracking (Left/Right) ---
	if not is_preparing_attack:
		# Only track the player if NOT preparing an attack
		var target_x = player.global_position.x
		var direction = sign(target_x - global_position.x)
		velocity.x = direction * horizontal_speed
		
		if abs(target_x - global_position.x) < 5.0:
			velocity.x = 0
	else:
		# Lock her in place horizontally while she telegraphs!
		velocity.x = 0 
		
	# --- Y-Axis Tracking (The Treadmill Slasher) ---
	var is_moving_down = Input.is_action_pressed("move_down")
	
	if is_moving_down:
		var safe_y = player.global_position.y - 80.0
		velocity.y = (safe_y - global_position.y) * 4.0 
		
		# --- NEW: Telegraph Attack Logic ---
		if not is_preparing_attack:
			shoot_timer += delta
			if shoot_timer >= fire_rate: # Example: Fires every 2.0 or 3.0 seconds
				_telegraph_and_fire()
				shoot_timer = 0.0
			
	else:
		velocity.y = 150.0 # Dive-bomb
		
	move_and_slide()

# --- NEW: The Telegraph Sequence ---
# --- NEW: The Fixed-Lane Telegraph Sequence ---
func _telegraph_and_fire() -> void:
	is_preparing_attack = true
	
	# 1. Define fixed GLOBAL X-coordinates for your lanes.
	# These lock the attacks exactly between your invisible walls, regardless of where the boss is!
	# (You may need to tweak these numbers to perfectly fit your dirt path)
	var possible_lanes_x = [-80.0, -40.0, 0.0, 40.0, 80.0] 
	
	# 2. Shuffle the array to randomize it, then grab the first 3!
	possible_lanes_x.shuffle()
	var chosen_lanes = [possible_lanes_x[0], possible_lanes_x[1], possible_lanes_x[2]]
	
	# 3. Spawn the Warning Lines in the chosen fixed lanes
	for lane_x in chosen_lanes:
		if warning_line_scene != null:
			var warning = warning_line_scene.instantiate()
			get_parent().add_child(warning)
			
			# Use the fixed lane_x, but keep the boss's Y height
			warning.global_position = Vector2(lane_x, global_position.y)
			
	# 4. Wait 0.8 seconds to give the player time to dodge
	await get_tree().create_timer(0.8).timeout
	
	# 5. Fire the spears down those exact fixed lanes!
	for lane_x in chosen_lanes:
		if blood_spear_scene != null:
			var spear = blood_spear_scene.instantiate()
			get_parent().add_child(spear)
			
			# Start at the exact same X coordinate the warning line used
			spear.global_position = Vector2(lane_x, global_position.y)
			spear.direction = Vector2.DOWN 
			
	# 6. Un-lock her movement so she can track the player again
	is_preparing_attack = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("THE MANANANGGAL CAUGHT YOU!")
		if body.has_method("die"):
			body.die()
		var arena = get_parent()
		if arena.has_method("end_chase"):
			arena.end_chase()
