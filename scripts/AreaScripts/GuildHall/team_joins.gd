extends Area2D

@export var next_area_path: String = "res://scenes/CutScenes/party_join.tscn"
@export var entry_group: String = "party_join_marker"  # optional marker group if needed

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		# Only activate if quest accepted
		if GameState.story_stage >= 2 and GameState.active_quest != "" and GameState.story_stage != 3:
			print("Trigger activated: Party join cutscene")
			var gameplay = get_tree().current_scene
			gameplay.load_area(next_area_path, entry_group)
		else:
			print("Trigger inactive — quest not accepted yet")
