extends Area2D

@export var next_area_path: String = "res://scenes/GameLevels/Areas/boss_fight_scene.tscn"
@export var entry_group: String = "forest_exit"

func _on_body_entered(body):
	if body.name == "Player":
		var gameplay = get_tree().current_scene
		gameplay.load_area(next_area_path, entry_group)
