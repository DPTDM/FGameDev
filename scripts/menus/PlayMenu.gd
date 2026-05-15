extends Control

# PlayMenu.gd
# Secondary menu reached from the Main Menu's Play button.
# Provides navigation to Characters, Worlds, Weapons, and Items.

func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)
	$CenterContainer/VBoxContainer/CharactersButton.pressed.connect(_on_characters_pressed)
	$CenterContainer/VBoxContainer/WorldsButton.pressed.connect(_on_worlds_pressed)
	$CenterContainer/VBoxContainer/WeaponsButton.pressed.connect(_on_weapons_pressed)
	$CenterContainer/VBoxContainer/ItemsButton.pressed.connect(_on_items_pressed)


func _on_back_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/MainMenu.tscn")


func _on_characters_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/CharacterSelect.tscn")


func _on_worlds_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/WorldSelect.tscn")


func _on_weapons_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/WeaponsMenu.tscn")


func _on_items_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/ItemsMenu.tscn")
