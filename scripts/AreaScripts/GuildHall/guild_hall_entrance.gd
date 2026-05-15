extends Area2D

# BUG FIX: was "res://scenes/GameLevels/Areas/city.tscn" (lowercase 'c').
# The actual file on disk is City.tscn (uppercase 'C'). On Linux/export builds
# the filesystem is case-sensitive and the lowercase path causes a load failure.
@export var next_area_path: String = "res://scenes/GameLevels/Areas/City.tscn"
@export var entry_group: String = "outside_of_guildhall"

func _on_body_entered(body):
	if body.name == "Player":
		var gameplay = get_tree().current_scene
		gameplay.load_area(next_area_path, entry_group)
