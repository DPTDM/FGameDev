extends CanvasLayer

@onready var panel = $Panel
@onready var resume_button = $Panel/VBoxContainer/Resume
@onready var settings_button = $Panel/VBoxContainer/Settings
@onready var quit_button = $Panel/VBoxContainer/QuitToTitle
@onready var settings_menu = $SettingsMenu

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS   # keep working while paused
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if visible:
		resume_game()
	else:
		pause_game()

func pause_game():
	visible = true
	panel.visible = true
	settings_menu.visible = false
	get_tree().paused = true

func resume_game():
	visible = false
	get_tree().paused = false

func _on_resume_pressed():
	resume_game()

func _on_settings_pressed():
	panel.visible = false
	settings_menu.visible = true

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
