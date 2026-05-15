extends Control

# CharacterSelect.gd
# Displays character information only. Selection will be added in a future update.

func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/PlayMenu.tscn")
