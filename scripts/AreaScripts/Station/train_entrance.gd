extends Area2D

@export var next_area_path: String = "res://scenes/CutScenes/TrainScene.tscn"
@export var entry_group: String = "sitio_village_entrance"

# Set this to whatever story stage the player needs to reach before the train unlocks!
@export var required_story_stage: int = 3

func _on_body_entered(body):
	if body.name == "Player":
		# 1. CHECK THE CONDITION
		if GameState.story_stage >= required_story_stage:
			# If they meet the requirement, transition normally!
			var gameplay = get_tree().current_scene
			gameplay.load_area(next_area_path, entry_group)
			
		else:
			# 2. IF LOCKED, PUSH BACK
			# The train is locked! Give the player feedback so they aren't confused.
			var ui = get_node_or_null("/root/GamePlay/DialogueUI")
			
			if ui and not ui.visible:
				var locked_text = [
					{"name": "System", "text": "The train to Sitio Dihscember is currently out of service.", "portrait": "res://icon.svg"},
					{"name": "Player", "text": "I should probably finish my tasks at the Guildhall first.", "portrait": "res://icon.svg"}
				]
				ui.start_conversation(locked_text)
