extends StaticBody2D

var is_player_in_range: bool = false

@onready var quest_area: Area2D = $InteractionArea

func _ready() -> void:
	quest_area.body_entered.connect(_on_player_entered)
	quest_area.body_exited.connect(_on_player_exited)

func _on_player_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_player_in_range = true

func _on_player_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_player_in_range = false

func _input(event: InputEvent) -> void:
	if is_player_in_range and event.is_action_pressed("interact"):
		start_quest_dialogue()

func start_quest_dialogue() -> void:
	var ui = get_tree().current_scene.get_node_or_null("DialogueUI")
	if ui == null:
		return
	var full_script = [
		{"name": "Quest Board", "text": "[Quest Notice]\nRank: F...", "portrait": ""},
		{"name": "Narrator", "text": "The first is a pink-haired girl with a staff strapped to her back. She smiles nervously, clutching it tightly.", "portrait": ""},
		{"name": "Pink-Haired Girl", "text": "Hello! Could we perhaps join you?", "portrait": "res://icon.svg"},
		{"name": "Narrator", "text": "Then, as if afraid of rejection, she quickly adds,", "portrait": ""},
		{"name": "Pink-Haired Girl", "text": "I-I can heal you if you're ever in trouble!", "portrait": "res://icon.svg"},
		{"name": "Narrator", "text": "Beside her stands a tall boy with short silver hair, clad in reinforced armor. A heavy shield rests on his arm, and his calm expression radiates confidence.", "portrait": ""},
		{"name": "Silver Hair Boy", "text": "And I'll be your shield. If something tries to tear you apart, it'll have to go through me first.", "portrait": "res://icon.svg"}
	]
	Global.story_stage = 2
	ui.start_conversation("Quest Notice", full_script)
