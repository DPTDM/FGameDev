extends Node2D

@onready var esc_menu: CanvasLayer = $EscMenu
@onready var esc_panel: Control = $EscMenu/Blocker
var is_menu_open := false

func _ready() -> void:
	esc_panel.visible = false
	$EscMenu/Panel/VBox/ResumeBtn.pressed.connect(_close_menu)
	$EscMenu/Panel/VBox/SettingsBtn.pressed.connect(_on_settings)
	$EscMenu/Panel/VBox/ExitBtn.pressed.connect(_on_exit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_menu_open:
			_close_menu()
		else:
			_open_menu()

func _open_menu() -> void:
	is_menu_open = true
	esc_panel.visible = true
	$EscMenu/Panel.visible = true
	get_tree().paused = true

func _close_menu() -> void:
	is_menu_open = false
	esc_panel.visible = false
	$EscMenu/Panel.visible = false
	get_tree().paused = false

func _on_settings() -> void:
	pass

func _on_exit() -> void:
	get_tree().paused = false
	SceneTransition.fade_to("res://scenes/menus/MainMenu.tscn")
