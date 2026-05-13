extends Node2D

@onready var scrolling_layer: ParallaxLayer = $ParallaxBackground/ScrollingForest 
@onready var parallax_bg: ParallaxBackground = $ParallaxBackground
@onready var boss = $Character/Boss 
@export var survive_time := 20.0 
var time_survived := 0.0
@export var demo_complete_scene: PackedScene

@export var scroll_speed := 400.0 
var is_chasing := false 

func _ready() -> void:
	boss.connect("chase_started", _on_boss_chase_started)

func _on_boss_chase_started() -> void:
	is_chasing = true
	print("The Chase Begins!")

func _process(delta: float) -> void:
	if is_chasing:
		scrolling_layer.motion_offset.y -= scroll_speed * delta
		
		# --- NEW: The Survival Clock ---
		time_survived += delta
		if time_survived >= survive_time:
			end_chase()

func end_chase() -> void:
	is_chasing = false
	
	GameState.active_quest = "Return to the Guild (Completed!)"
	GameState.story_stage = 3
	print("YOU SURVIVED!")
	
	# 1. Slow the treadmill down smoothly
	var tween = create_tween()
	tween.tween_property(self, "scroll_speed", 0.0, 2.0).set_trans(Tween.TRANS_SINE)
	
	# 2. Tell the boss to retreat!
	if boss.has_method("retreat"):
		boss.retreat()
		
	# 3. Wait 3.5 seconds to watch her fly away
	await get_tree().create_timer(3.5).timeout
	
	# 4. Summon the Demo Complete Screen!
	if demo_complete_scene != null:
		var victory_screen = demo_complete_scene.instantiate()
		get_tree().root.add_child(victory_screen)
		
		# Pause the background action so the player can soak in the victory
		get_tree().paused = true
