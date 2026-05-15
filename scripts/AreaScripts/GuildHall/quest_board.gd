extends Area2D

@onready var prompt_label: Label = $InteractionLabel
var is_player_in_range: bool = false
var quest_modal_scene = preload("res://scenes/ui/quest_modal.tscn")  # adjust path
	
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
	if is_player_in_range and event.is_action_pressed("interact"):
		if GameState.story_stage == 1:   # only usable after Receptionist
			print("DEBUG: E pressed near QuestBoard")
			open_quest_modal()

func open_quest_modal():
	var modal = quest_modal_scene.instantiate()
	get_tree().current_scene.add_child(modal)
	modal.popup_centered()   # sets visible + centers
