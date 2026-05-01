extends Control

# WorldSelect.gd
# 2x2 grid: Philippines, two locked placeholders, Practice.

const PHILIPPINES_FADE_DURATION := 1.5

var _weapon_popup: Control = null

func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)
	$CardArea/CenterContainer/WorldGrid/WorldCard0/VBox0/EnterBtn0.pressed.connect(_on_philippines_selected)
	$CardArea/CenterContainer/WorldGrid/WorldCardPractice/VBoxPractice/EnterBtnPractice.pressed.connect(_on_practice_selected)

func _on_philippines_selected() -> void:
	GameState.selected_world = 0
	#MenuMusic.play_lobby()
	SceneTransition.fade_to("res://scenes/world/guild_hall.tscn", PHILIPPINES_FADE_DURATION)

func _on_practice_selected() -> void:
	var popup_scene = load("res://scenes/menus/WeaponSelectPopup.tscn")
	_weapon_popup = popup_scene.instantiate()
	add_child(_weapon_popup)
	_weapon_popup.weapon_chosen.connect(_on_weapon_chosen)

func _on_weapon_chosen(weapon_name: String) -> void:
	Global.specialization = weapon_name
	if _weapon_popup:
		_weapon_popup.queue_free()
		_weapon_popup = null
	#MenuMusic.stop()
	SceneTransition.fade_to("res://scenes/world/PracticeWorld.tscn")

func _on_back_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/PlayMenu.tscn")
