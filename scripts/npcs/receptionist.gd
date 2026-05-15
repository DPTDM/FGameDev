extends Area2D

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
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui and ui.visible:
		return

	if is_player_in_range and event.is_action_pressed("interact"):
		start_receptionist_dialogue()

func start_receptionist_dialogue() -> void:
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui == null:
		return

	match GameState.story_stage:
		0:
			var reg_script = [
				{"name": "Receptionist", "text": "Welcome to the Anti-Mythics Guild.", "portrait": "res://icon.svg"},
				{"name": "Receptionist", "text": "Before we begin, may I know your name?", "portrait": "res://icon.svg", "input": true},
				{"name": "Receptionist", "text": "Nice to meet you, {player}! What is your gender?", "portrait": "res://icon.svg", "choices": ["Male", "Female", "Other"]},
				{"name": "Receptionist", "text": "And what is your specialization in weapons?", "portrait": "res://icon.svg", "specialization": true},
				{"name": "Receptionist", "text": "Excellent, {player}, the Quest Board awaits you.", "portrait": "res://icon.svg"}
			]
			ui.start_conversation(reg_script)
			await ui.dialogue_finished
			# 👇 ensure stage advances
			if GameState.story_stage == 0:
				GameState.story_stage = 1
			print("DEBUG: Receptionist finished, stage =", GameState.story_stage)

		1:
			var quest_part = [
				{"name": "Receptionist", "text": "Ah, {player}, the Quest Board is over there. Take a look.", "portrait": "res://icon.svg"}
			]
			ui.start_conversation(quest_part)
			await ui.dialogue_finished
			GameState.story_stage = 2
			
		# --- NEW: Added for after the Cutscene (Stage 3 and above) ---
		3, _: 
			var post_cutscene = [
				{"name": "Receptionist", "text": "Your party is waiting for you, {player}.", "portrait": "res://icon.svg"},
				{"name": "Receptionist", "text": "The train to Sitio Dihsembr is ready whenever you are. Be careful out there.", "portrait": "res://icon.svg"}
			]
			ui.start_conversation(post_cutscene)
			await ui.dialogue_finished
			
			# We don't advance the stage here, because the player is now free to leave the building!
