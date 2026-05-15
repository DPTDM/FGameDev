extends Area2D

@export var npc_name: String = "Unknown"
@export var portrait_path: String = "res://icon.svg"
@export var dialogue_texts: Array[String] = []

var is_player_in_range: bool = false
@onready var prompt_label: Label = $InteractionLabel

func _ready() -> void:
	prompt_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_player_in_range = true
		prompt_label.visible = true
	
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_player_in_range = false
		prompt_label.visible = false

func _input(event: InputEvent) -> void:
	# Check for your DialogueUI exactly like the Receptionist does
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui and ui.visible:
		return

	if is_player_in_range and event.is_action_pressed("interact"):
		start_background_dialogue()

func start_background_dialogue() -> void:
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui == null or dialogue_texts.is_empty():
		return

	# Hide the interaction prompt while talking
	prompt_label.visible = false 

	# Auto-build the dictionary format your UI requires
	var script_array = []
	for text in dialogue_texts:
		script_array.append({
			"name": npc_name,
			"text": text,
			"portrait": portrait_path
		})
		
	ui.start_conversation(script_array)
	await ui.dialogue_finished
	
	# Bring the prompt back if the player is still standing there
	if is_player_in_range:
		prompt_label.visible = true
