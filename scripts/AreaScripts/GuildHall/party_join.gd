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
	anim.animation_finished.connect(_on_finish_animation)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

	# Play intro animation
	anim.play("party_join")

func _on_animation_finished(anim_name: String):
	if anim_name == "party_join":
		dialogue_ui.start_conversation([
			{"name": "Narrator", "text": "[Player] glances down in thought..."},
			{"name": "Althea", "text": "Could we perhaps join you on this quest? I-I can heal you if you’re ever in trouble!"},
			{"name": "Ashton", "text": "And I’ll be your shield. If something tries to tear you apart, it’ll have to go through me first."},
			{"choices": [
				"Accept (Easy Mode)",
				"Refuse (Hard Mode) (disabled)"
			]}
		])


func _on_dialogue_finished():
	# After dialogue, play outro animation before returning
	anim.play("after_join")

func _on_finish_animation(anim_name: String):
	if anim_name == "after_join":
		# Re-enable player controls
		var player = get_node_or_null("/root/GamePlay/Player")
		if player:
			player.can_control = true

		# Advance story stage
		GameState.story_stage = 3
		#GameState.has_party = true  # mark that Ashton & Althea joined

		# Receptionist confirmation dialogue
		dialogue_ui.start_conversation([
			{"name": "Receptionist", "text": "You three have been registered. Good luck on your mission!", "portrait": "res://icon.svg"}
		])

		# Wait until that short dialogue finishes, then transition
		dialogue_ui.dialogue_finished.connect(func():
			var gameplay = get_tree().root.get_node("GamePlay")
			gameplay.load_area("res://scenes/GameLevels/Areas/guild_hall.tscn", "after_join"))
