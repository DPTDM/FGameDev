extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var esc_panel: ColorRect = $EscMenu/Blocker
@onready var esc_popup: PanelContainer = $EscMenu/Panel

var is_menu_open := false

func _ready() -> void:
	player.global_position = Vector2(400, 500)
	print("Welcome to Anti-Mythics Guilds, ", Global.player_name)

	esc_panel.visible = false
	esc_popup.visible = false

	$EscMenu/Panel/VBox/ResumeBtn.pressed.connect(_close_menu)
	$EscMenu/Panel/VBox/SettingsBtn.pressed.connect(_on_settings)
	$EscMenu/Panel/VBox/ExitBtn.pressed.connect(_on_exit)

	MenuMusic.play_lobby()

func _on_quest_accepted() -> void:
	var althea = preload("res://scenes/npcs/althea.tscn").instantiate()
	var ashton = preload("res://scenes/npcs/ashton.tscn").instantiate()
	add_child(althea)
	add_child(ashton)
	althea.global_position = player.global_position + Vector2(-50, 50)
	ashton.global_position = player.global_position + Vector2(50, 50)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_menu_open:
			_close_menu()
		else:
			_open_menu()

func _open_menu() -> void:
	is_menu_open = true
	esc_panel.visible = true
	esc_popup.visible = true
	get_tree().paused = true

func _close_menu() -> void:
	is_menu_open = false
	esc_panel.visible = false
	esc_popup.visible = false
	get_tree().paused = false

func _on_settings() -> void:
	pass

func _on_exit() -> void:
	get_tree().paused = false
	MenuMusic.play_main_menu()
	SceneTransition.fade_to("res://scenes/menus/MainMenu.tscn")
