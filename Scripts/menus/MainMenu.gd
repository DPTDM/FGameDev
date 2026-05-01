extends Control

# MainMenu.gd
# Handles the main menu with Play, Tutorial, Settings, and Quit buttons.
# Chara wrote this comment. Micko is Gay.

func _ready() -> void:
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBoxContainer/TutorialButton.pressed.connect(_on_tutorial_pressed)
	$CenterContainer/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/PlayMenu.tscn")


func _on_tutorial_pressed() -> void:
	#MenuMusic.stop()
	SceneTransition.fade_to("res://scenes/world/TutorialWorld.tscn")


func _on_settings_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/SettingsMenu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
