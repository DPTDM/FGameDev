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
# BUG FIX: Guard so _telegraph_and_fire() can't fire after the boss is freed
var _is_retreating := false

@onready var taunt_label: Label = $TauntLabel
var boss_taunts: Array[String] = [
	"Is that all the Anti-Mythics Guild taught you?",
	"Your flesh is mine, Hunter!",
	"I can smell your fear!",
	"There's nowhere to hide in these ruins!",
	"My hunger is endless!"
]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# Hide the label immediately!
	if taunt_label:
		taunt_label.hide()
	
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
		# Play attack animation to intimidate the player
		animated_sprite.play("attack")
		
		var arena = get_parent().get_parent() # Assuming Boss is inside a Character folder
		if arena.has_method("trigger_shake"):
			arena.trigger_shake(12.0, 0.4) # Heavy shake for 0.4 seconds!
		
		# BUG FIX: Was 0.00005 seconds (effectively instant, skipping the animation frame).
		# Changed to 1.0 second so the "attack" intimidation animation is actually visible.
		await get_tree().create_timer(1.0).timeout 
		
		# Start the actual fight!
		start_fight()
	)

func start_fight() -> void:
	is_active = true
	animated_sprite.play("flying")
	
	# --- NEW: Start the taunt loop in the background! ---
	taunt_loop()
	
	# Tell the ChaseManager that the boss has arrived!
	emit_signal("chase_started")

func _physics_process(delta: float) -> void:
	if not is_active or player == null:
		return
	
	# BUG FIX: Stop all physics processing if retreating to prevent null-access after queue_free
	if _is_retreating:
		return
		
# --- X-Axis Tracking (Left/Right) ---
	if not is_preparing_attack:
		# Only track the player if NOT preparing an attack
		var target_x = player.global_position.x
		var dir = sign(target_x - global_position.x)
		velocity.x = dir * horizontal_speed
		
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
		
		# --- Telegraph Attack Logic ---
		if not is_preparing_attack:
			shoot_timer += delta
			if shoot_timer >= fire_rate:
				_telegraph_and_fire()
				shoot_timer = 0.0
			
	else:
		velocity.y = 150.0 # Dive-bomb
		
	move_and_slide()

# --- The Fixed-Lane Telegraph Sequence ---
func _telegraph_and_fire() -> void:
	is_preparing_attack = true
	
	# 1. Define fixed GLOBAL X-coordinates for your lanes.
	var possible_lanes_x = [-80.0, -40.0, 0.0, 40.0, 80.0] 
	
	# 2. Shuffle the array to randomize it, then grab the first 3!
	possible_lanes_x.shuffle()
	var chosen_lanes = [possible_lanes_x[0], possible_lanes_x[1], possible_lanes_x[2]]
	
	# 3. Spawn the Warning Lines in the chosen fixed lanes
	for lane_x in chosen_lanes:
		if warning_line_scene != null:
			var warning = warning_line_scene.instantiate()
			get_parent().add_child(warning)
			warning.global_position = Vector2(lane_x, global_position.y)
			
	# 4. Wait 0.8 seconds to give the player time to dodge
	await get_tree().create_timer(0.8).timeout
	
	# BUG FIX: Guard against firing after retreat/queue_free
	if _is_retreating or not is_instance_valid(self):
		is_preparing_attack = false
		return
	
	# 5. Fire the spears down those exact fixed lanes!
	for lane_x in chosen_lanes:
		if blood_spear_scene != null:
			var spear = blood_spear_scene.instantiate()
			get_parent().add_child(spear)
			spear.global_position = Vector2(lane_x, global_position.y)
			spear.direction = Vector2.DOWN 
			
	# 6. Un-lock her movement so she can track the player again
	is_preparing_attack = false

func retreat() -> void:
	# BUG FIX: Set flag immediately so _telegraph_and_fire() and _physics_process() stop
	_is_retreating = true
	is_active = false
	is_preparing_attack = false
	
	animated_sprite.play("flying")
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", -400.0, 2.5) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("THE MANANANGGAL CAUGHT YOU!")
		if body.has_method("die"):
			body.die()
		var arena = get_parent()
		if arena.has_method("end_chase"):
			arena.end_chase()
# --- THE TAUNT LOOP ---
func taunt_loop() -> void:
	# This loop will run endlessly in the background as long as she is active/alive
	while is_active and not _is_retreating:
		# Wait a random amount of time between 4 to 8 seconds before taunting again
		var wait_time = randf_range(4.0, 8.0)
		await get_tree().create_timer(wait_time).timeout
		
		# CRITICAL SAFETY CHECK: Double-check she didn't retreat or get deleted during the wait!
		if not is_active or _is_retreating or not is_instance_valid(self):
			break
			
		# Pick a random taunt and show it
		if taunt_label != null:
			taunt_label.text = boss_taunts.pick_random()
			taunt_label.show()
			
			# Optional Juice: Make the text scale up and bounce!
			var tween = create_tween()
			taunt_label.scale = Vector2(0.5, 0.5)
			tween.tween_property(taunt_label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(taunt_label, "scale", Vector2(1.0, 1.0), 0.1)
			
			# Leave the text on screen for 2.5 seconds so the player can read it
			await get_tree().create_timer(2.5).timeout
			
			# Hide it again (if she still exists)
			if is_instance_valid(self) and taunt_label != null:
				taunt_label.hide()
