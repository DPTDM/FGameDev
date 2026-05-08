extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var dialogue_ui = $DialogueUI

func _ready():
	# Disable player controls
	var player = get_node_or_null("/root/GamePlay/Player")
	if player:
		player.can_control = false

	# Connect signals once
	anim.animation_finished.connect(_on_animation_finished)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

	# Play animation
	anim.play("party_join")

func _on_animation_finished(anim_name: String):
	if anim_name == "party_join":
		dialogue_ui.start_conversation([
			{"name": "Ashton", "text": "I’ll protect the team up front!"},
			{"name": "Althea", "text": "I can heal you if you’re ever in trouble!"},
			{"name": "Receptionist", "text": "Your party is complete. Good luck on your quest!"}
		])

func _on_dialogue_finished():
	# Re-enable player controls
	var player = get_node_or_null("/root/GamePlay/Player")
	if player:
		player.can_control = true

	# Advance story stage
	GameState.story_stage = 3

	# Return to Gameplay and load next area
	var gameplay = get_tree().root.get_node("GamePlay")
	gameplay.load_area("res://scenes/GameLevels/Areas/guild_hall.tscn", "after_join")
