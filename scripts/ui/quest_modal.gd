extends PopupPanel

@onready var quest1_button = $"TabContainer/F-Rank/MarginContainer/Quest 1"
@onready var quest1_details = $"TabContainer/F-Rank/MarginContainer/QuestDetails1"
# Ensure this path matches your new RichTextLabel!
@onready var quest_description = $"TabContainer/F-Rank/MarginContainer/QuestDetails1/VBox/QuestDescription" 
@onready var accept_button = $"TabContainer/F-Rank/MarginContainer/QuestDetails1/VBox/HBox/Accept"
@onready var back_button = $"TabContainer/F-Rank/MarginContainer/QuestDetails1/VBox/HBox/Back"

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
	
	# Using BBCode to create a beautiful, structured layout!
	quest_description.text = """[center][b][color=gold]Investigate mysterious deaths in Beringan[/color][/b][/center]

[center][img width=600]res://assets/art/Maps/SitioDihsembr.png[/img][/center]

[b]Rank:[/b] F
[b]Date:[/b] 1 Day Ago

[b]Report:[/b] Local civilians have reported strange cases of people failing to wake up.
[b]Location:[/b] Beringan Town
[b]Casualties:[/b] Two victims confirmed dead.
[b]Findings:[/b] Autopsy reports indicate their organs were consumed from within, though no external wounds were found.

[color=red]Cause unknown.[/color]"""

func _on_accept_pressed():
	GameState.active_quest = "Investigate mysterious deaths in Beringan"
	GameState.story_stage = 2
	hide()
	print("Quest accepted:", GameState.active_quest)

func _on_back_pressed():
	quest1_details.hide()
	quest1_button.show()
