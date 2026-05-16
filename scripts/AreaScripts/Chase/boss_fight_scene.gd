extends Node2D

@onready var scrolling_layer: ParallaxLayer = $ParallaxBackground/ScrollingForest 
@onready var parallax_bg: ParallaxBackground = $ParallaxBackground
@onready var boss = $Character/Boss 
@export var survive_time := 20.0 
var time_survived := 0.0
@export var demo_complete_scene: PackedScene

@export var scroll_speed := 400.0 
var is_chasing := false 

# --- OBSTACLE VARIABLES ---
@export var obstacle_scene: PackedScene # Drag your obstacle.tscn here in the Inspector!
var obstacle_spawn_timer := 0.0
@export var spawn_rate := 1.5 
var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var active_camera: Camera2D
@onready var fade_screen: ColorRect = $CanvasLayer/FadeScreen

# --- NEW: CAMERA LIMIT MARKERS ---
@onready var top_left: Marker2D = $Node/TopLeft
@onready var bottom_right: Marker2D = $Node/BottomRight

func _ready() -> void:
	boss.connect("chase_started", _on_boss_chase_started)
	
	# --- NEW: DELAY AND SETUP ---
	# Wait exactly 0.1 seconds to guarantee the Player has fully spawned in!
	await get_tree().create_timer(0.1).timeout
	setup_camera_limits()

# --- NEW: THE CAMERA LIMIT FUNCTION ---
func setup_camera_limits() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("BOSS CAMERA ERROR: Could not find player!")
		return
		
	# Notice we use "POV" here to match your updated player camera!
	if player.has_node("POV"):
		var cam = player.get_node("POV")
		
		# 1. Turn OFF smoothing temporarily
		# 1. Turn OFF smoothing temporarily
		cam.position_smoothing_enabled = false
		
		# 2. Lock the limits
		cam.limit_left = int(top_left.global_position.x)
		cam.limit_top = int(top_left.global_position.y)
		cam.limit_right = int(bottom_right.global_position.x)
		cam.limit_bottom = int(bottom_right.global_position.y)
		
		# 3. Use the correct Godot 4 command!
		cam.reset_smoothing() 
		
		# 4. Turn smoothing back on for gameplay
		cam.position_smoothing_enabled = true
		
		# Save this camera to our active_camera variable for Screen Shake
		active_camera = cam
		
		print("SUCCESS: Boss Arena Camera locked and centered!")
	else:
		print("BOSS CAMERA ERROR: Could not find 'POV' inside player!")

func _on_boss_chase_started() -> void:
	is_chasing = true
	print("The Chase Begins!")

func _process(delta: float) -> void:
	if is_chasing:
		# --- 1. CALCULATE TENSION PROGRESS ---
		var progress = time_survived / survive_time 
		
		# --- 2. ESCALATE THE DIFFICULTY (LERP) ---
		scroll_speed = lerp(400.0, 900.0, progress)
		
		if is_instance_valid(boss):
			boss.fire_rate = lerp(1.5, 0.4, progress)
			
		spawn_rate = lerp(1.5, 0.6, progress)
		
		# --- 3. APPLY THE MOVEMENT ---
		scrolling_layer.motion_offset.y -= scroll_speed * delta
		
		# --- 4. RUN THE SPAWNERS & CLOCK ---
		obstacle_spawn_timer += delta
		if obstacle_spawn_timer >= spawn_rate:
			spawn_obstacle()
			obstacle_spawn_timer = 0.0
			
		time_survived += delta
		if time_survived >= survive_time:
			end_chase()
			
	# --- SCREEN SHAKE ENGINE ---
	if active_camera:
		if shake_timer > 0:
			shake_timer -= delta
			active_camera.offset = Vector2(
				randf_range(-shake_intensity, shake_intensity), 
				randf_range(-shake_intensity, shake_intensity)
			)
		elif active_camera.offset != Vector2.ZERO:
			active_camera.offset = Vector2.ZERO
			
func trigger_shake(intensity: float = 8.0, duration: float = 0.2) -> void:
	active_camera = get_viewport().get_camera_2d() 
	shake_intensity = intensity
	shake_timer = duration
			
func spawn_obstacle() -> void:
	if obstacle_scene == null:
		return
		
	var obs = obstacle_scene.instantiate()
	add_child(obs)
	
	var possible_lanes_x = [-80.0, -40.0, 0.0, 40.0, 80.0]
	var random_x = possible_lanes_x.pick_random()
	
	obs.global_position = Vector2(random_x, 800.0)
	obs.speed = scroll_speed

func end_chase() -> void:
	is_chasing = false
	
	GameState.active_quest = "Return to the Guild (Completed!)"
	GameState.story_stage = 3
	print("YOU SURVIVED!")
	
	var tween = create_tween()
	tween.tween_property(self, "scroll_speed", 0.0, 2.0).set_trans(Tween.TRANS_SINE)
	
	if boss.has_method("retreat"):
		boss.retreat()
		
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_screen, "modulate:a", 1.0, 3.5)
	await fade_tween.finished
	
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui:
		var cliffhanger_text = [
			{"name": "System", "text": "QUEST COMPLETED: Survive the Night.", "portrait": "res://icon.svg"},
			{"name": "???", "text": "You survived... for now. But the Guild cannot protect you forever.", "portrait": "res://icon.svg"} 
		]
		ui.start_conversation(cliffhanger_text)
		await ui.dialogue_finished
	
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")
