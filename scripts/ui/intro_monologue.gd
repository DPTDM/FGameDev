extends Control

@onready var text_label = $Label
# Make sure this path exactly matches where your guild_hall.tscn is saved!
@export var next_scene_path: String = "res://scenes/GameLevels/GamePlay.tscn" 

# Write your cinematic lines here!
var monologue_lines = [
	"The night is cold...",
	"The Guild demands perfection from its Hunters.",
	"But perfection comes at a cost.",
	"Welcome to the hunt."
]

func _ready() -> void:
	# Make the text completely invisible when the scene first loads
	text_label.modulate.a = 0.0
	play_monologue()

func play_monologue() -> void:
	# Wait 1 second before showing the first line
	await get_tree().create_timer(1.0).timeout
	
	for line in monologue_lines:
		text_label.text = line
		
		# 1. Fade the text IN over 1.5 seconds
		var fade_in = create_tween()
		fade_in.tween_property(text_label, "modulate:a", 1.0, 1.5)
		await fade_in.finished
		
		# 2. Leave the text on screen so the player can read it (2.5 seconds)
		await get_tree().create_timer(2.5).timeout
		
		# 3. Fade the text OUT over 1.5 seconds
		var fade_out = create_tween()
		fade_out.tween_property(text_label, "modulate:a", 0.0, 1.5)
		await fade_out.finished
		
		# Wait half a second of pure darkness before the next line
		await get_tree().create_timer(0.5).timeout
		
	# Once all lines are done, transition to the Guildhall!
	TransitionScreen.fade_to(next_scene_path, 1.0)
	
# Optional: Let the player skip the intro if they mash the interact button
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		TransitionScreen.fade_to(next_scene_path)
