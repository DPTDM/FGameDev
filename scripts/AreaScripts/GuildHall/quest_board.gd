extends Area2D

@onready var prompt_label: Label = $InteractionLabel
var is_player_in_range: bool = false
var quest_modal_scene = preload("res://scenes/ui/quest_modal.tscn")

func _ready():
	prompt_label.visible = false
	# BUG FIX: signal connections were missing — body_entered/exited never fired
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

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
		# Only usable at stage 1 (after Receptionist intro, before quest accepted)
		if GameState.story_stage == 1:
			print("DEBUG: E pressed near QuestBoard")
			open_quest_modal()

func open_quest_modal():
	var modal = quest_modal_scene.instantiate()
	get_tree().current_scene.add_child(modal)
	# BUG FIX: do NOT call popup_centered() here — quest_modal._ready() already
	# calls popup_centered(), so calling it again caused a double-popup flash.
	# Just add_child(); _ready() handles centering and visibility automatically.
