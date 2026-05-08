extends Area2D

var is_player_in_range: bool = false
@onready var prompt_label: Label = $InteractionLabel

func _ready():
	prompt_label.visible = false

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		is_player_in_range = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		is_player_in_range = false
		prompt_label.visible = false

func _input(event: InputEvent):
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui and ui.visible:
		return

	if is_player_in_range and event.is_action_pressed("interact"):
		print("DEBUG: E pressed near QuestBoard!")   # 👈 log to console
		start_quest_board_dialogue()

func start_quest_board_dialogue() -> void:
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui == null:
		return

	print("DEBUG: entering QuestBoard, stage =", GameState.story_stage)

	match GameState.story_stage:
		1:
			var quest_script = [
				{"name": "Quest Board", "text": "Available quests:", "portrait": "res://icon.svg"},
				{"name": "Quest Board", "text": "F-Rank: Investigate mysterious deaths in Beringan.", "portrait": "res://icon.svg", "choices": ["Accept", "Decline"]}
			]
			ui.start_conversation(quest_script)
			await ui.dialogue_finished
			GameState.story_stage = 2
