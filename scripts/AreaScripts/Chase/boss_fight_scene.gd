extends Node2D

@onready var scrolling_layer: ParallaxLayer = $ParallaxBackground/ScrollingForest 
@onready var parallax_bg: ParallaxBackground = $ParallaxBackground
@onready var boss = $Character/Boss 
@export var survive_time := 20.0 
var time_survived := 0.0
@export var demo_complete_scene: PackedScene

@export var scroll_speed := 400.0 
var is_chasing := false 
# --- NEW OBSTACLE VARIABLES ---
@export var obstacle_scene: PackedScene # Drag your obstacle.tscn here in the Inspector!
var obstacle_spawn_timer := 0.0
@export var spawn_rate := 1.5 #
var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var active_camera: Camera2D
@onready var fade_screen: ColorRect = $CanvasLayer/FadeScreen

func _ready() -> void:
	boss.connect("chase_started", _on_boss_chase_started)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("Camera2D"):
		active_camera = player.get_node("Camera2D")

func _on_boss_chase_started() -> void:
	is_chasing = true
	print("The Chase Begins!")

func _process(delta: float) -> void:
	if is_chasing:
		# --- 1. CALCULATE TENSION PROGRESS ---
		# This creates a value from 0.0 (start) to 1.0 (finish)
		var progress = time_survived / survive_time 
		
		# --- 2. ESCALATE THE DIFFICULTY (LERP) ---
		# Ground Speed: Starts at 400, ramps up to 900
		scroll_speed = lerp(400.0, 900.0, progress)
		
		# Boss Spears: Starts shooting every 1.5 seconds, ramps up to every 0.4 seconds!
		if is_instance_valid(boss):
			boss.fire_rate = lerp(1.5, 0.4, progress)
			
		# Log Obstacles: Starts spawning every 1.5 seconds, ramps up to every 0.6 seconds
		# (Make sure you change your 'spawn_rate' variable to this lerp!)
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
			
	if active_camera:
		if shake_timer > 0:
			shake_timer -= delta
			# Randomly aggressively shift the camera offset every frame
			active_camera.offset = Vector2(
				randf_range(-shake_intensity, shake_intensity), 
				randf_range(-shake_intensity, shake_intensity)
			)
		# Once the timer hits 0, snap the camera perfectly back to center
		elif active_camera.offset != Vector2.ZERO:
			active_camera.offset = Vector2.ZERO
			
func trigger_shake(intensity: float = 8.0, duration: float = 0.2) -> void:
	# Refresh the camera reference just in case it changed
	active_camera = get_viewport().get_camera_2d() 
	shake_intensity = intensity
	shake_timer = duration
			
func spawn_obstacle() -> void:
	if obstacle_scene == null:
		return
		
	var obs = obstacle_scene.instantiate()
	add_child(obs)
	
	# Pick a random lane (re-using the same math you used for the boss's spears!)
	var possible_lanes_x = [-80.0, -40.0, 0.0, 40.0, 80.0]
	var random_x = possible_lanes_x.pick_random()
	
	# Spawn at the very bottom of the screen (Adjust '800' based on your actual window height)
	obs.global_position = Vector2(random_x, 800.0)
	
	# Sync the rock's speed perfectly to the treadmill!
	obs.speed = scroll_speed

func end_chase() -> void:
	is_chasing = false
	
	GameState.active_quest = "Return to the Guild (Completed!)"
	GameState.story_stage = 3
	print("YOU SURVIVED!")
	
	# 1. Slow the treadmill down smoothly
	var tween = create_tween()
	tween.tween_property(self, "scroll_speed", 0.0, 2.0).set_trans(Tween.TRANS_SINE)
	
	# 2. Tell the boss to retreat
	if boss.has_method("retreat"):
		boss.retreat()
		
	# 3. Fade to Pitch Black over 3.5 seconds (Matches the time she flies away!)
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_screen, "modulate:a", 1.0, 3.5)
	await fade_tween.finished
	
	# 4. The screen is now black. Trigger the final Cliffhanger Dialogue!
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui:
		var cliffhanger_text = [
			{"name": "System", "text": "QUEST COMPLETED: Survive the Night.", "portrait": "res://icon.svg"},
			{"name": "???", "text": "You survived... for now. But the Guild cannot protect you forever.", "portrait": "res://icon.svg"} # Swap with a creepy monster eye portrait if you have one!
		]
		ui.start_conversation(cliffhanger_text)
		await ui.dialogue_finished
	
	# 5. Jump to the Credits Scene!
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")
