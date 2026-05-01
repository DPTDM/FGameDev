extends StaticBody2D

var is_player_in_range: bool = false

@onready var dialogue: Label = $InteractPrompt

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_player_in_range = true
		dialogue.visible = true

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_player_in_range = false
		dialogue.visible = false

func _input(event: InputEvent) -> void:
	if is_player_in_range and event.is_action_pressed("interact"):
		start_receptionist_dialogue()
		var player = get_tree().current_scene.get_node_or_null("Player")
		if player:
			player.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func start_receptionist_dialogue() -> void:
	var ui = get_node_or_null("/root/GuildHall/DialogueUI")
	if ui == null:
		return
	var registration_tablet = get_node_or_null("/root/GuildHall/Registration")

	if Global.story_stage == 0:
		var reg_script = [
			{"name": "Receptionist", "text": "Welcome to the Anti-Mythics Guild.", "portrait": "res://icon.svg"},
			{"name": "Receptionist", "text": "If you're ready, begin your registration.", "portrait": "res://icon.svg"}
		]
		ui.start_conversation("Receptionist", reg_script)
		await ui.dialogue_finished
		if registration_tablet:
			registration_tablet.visible = true
		Global.story_stage = 1

	elif Global.story_stage == 1:
		var quest_part = [
			{"name": "Receptionist", "text": "The Quest Board is over there. Check the [F] Rank section for new recruits.", "portrait": "res://icon.svg"}
		]
		ui.start_conversation("Receptionist", quest_part)

	elif Global.story_stage == 3:
		var final_script = [
			{"name": "Receptionist", "text": "I see you've formed a team with Althea and Ashton.", "portrait": "res://icon.svg"},
			{"name": "Receptionist", "text": "I've registered all three of you for the Manila investigation.", "portrait": "res://icon.svg"},
			{"name": "Receptionist", "text": "Good luck. The train bound for Beringan is waiting.", "portrait": "res://icon.svg"}
		]
		ui.start_conversation("Receptionist", final_script)
		await get_tree().create_timer(4.0, false).timeout
		get_tree().change_scene_to_file("res://scenes/world/beringan_train.tscn")
