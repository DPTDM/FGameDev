extends PopupPanel

@onready var quest1_button = $"TabContainer/F-Rank/Quest 1"
@onready var quest1_details = $"TabContainer/F-Rank/QuestDetails1"
@onready var quest_description = $"TabContainer/F-Rank/QuestDetails1/VBox/QuestDescription"
@onready var accept_button = $"TabContainer/F-Rank/QuestDetails1/VBox/HBox/Accept"
@onready var back_button = $"TabContainer/F-Rank/QuestDetails1/VBox/HBox/Back"

func _ready():
	popup_centered()
	quest1_details.hide()
	quest1_button.pressed.connect(_on_quest1_pressed)
	accept_button.pressed.connect(_on_accept_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_quest1_pressed():
	print("Quest 1 pressed, showing details")
	quest1_button.hide()
	quest1_details.show()
	quest_description.text = """[Quest Notice]
Rank: F
Date: 1 Day Ago
Report: Local civilians have reported strange cases of people failing to wake up.
Casualties: Two victims confirmed dead.
Findings: Autopsy reports indicate their organs were consumed from within, though no external wounds were found. Cause unknown.
"""

func _on_accept_pressed():
	GameState.active_quest = "Investigate mysterious deaths in Beringan"
	GameState.story_stage = 2
	hide()
	print("Quest accepted:", GameState.active_quest)

func _on_back_pressed():
	quest1_details.hide()
	quest1_button.show()
