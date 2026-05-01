extends Node2D

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	player.global_position = Vector2(400, 500)
	print("Welcome to Anti-Mythics Guilds, ", Global.player_name)

func _on_quest_accepted() -> void:
	var althea = preload("res://scenes/npcs/althea.tscn").instantiate()
	var ashton = preload("res://scenes/npcs/ashton.tscn").instantiate()
	add_child(althea)
	add_child(ashton)
	althea.global_position = player.global_position + Vector2(-50, 50)
	ashton.global_position = player.global_position + Vector2(50, 50)
