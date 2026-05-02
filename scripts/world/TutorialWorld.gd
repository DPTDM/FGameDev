extends Node2D

@onready var esc_panel: ColorRect = $EscMenu/Blocker
@onready var esc_popup: PanelContainer = $EscMenu/Panel
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var player: CharacterBody2D = $TutorialPlayer
@onready var hud_weapon_label: Label = $HUD/WeaponLabel
@onready var hud_hint_label: Label = $HUD/HintLabel
@onready var hp_label: Label = $HUD/StatsPanel/VBox/HPLabel
@onready var def_label: Label = $HUD/StatsPanel/VBox/DefLabel
@onready var effects_container: HBoxContainer = $HUD/EffectsPanel/VBoxOuter/EffectsBox

var is_menu_open := false
var death_popup_scene := preload("res://scenes/menus/DeathPopup.tscn")
var death_shown := false

# BUG FIX: Cache last known effects to avoid rebuilding labels every frame at 60fps
var _last_effects_snapshot: Array = []

const TUTORIAL_LINES := [
	{"name": "Guide", "text": "Welcome, adventurer! You have entered the Tutorial Grounds. Here you will learn everything you need to know before setting off into the world.", "portrait": ""},
	{"name": "Guide", "text": "Use W, A, S, D to move. Pick up a weapon with [E] and attack with Left Click.", "portrait": ""},
	{"name": "Guide", "text": "The Sword deals 5 physical damage. The Staff fires magic bolts dealing 3 damage — magic ignores armor.", "portrait": ""},
	{"name": "Guide", "text": "Two enemies patrol the area. A red Minion (50 HP, 4 dmg) and a purple Elite (100 HP, 10 dmg). They chase you when nearby!", "portrait": ""},
	{"name": "Guide", "text": "Consumables are placed around the grounds. Walk up to one and press [E] to use it. Health Potion restores 15 HP. Defense Potion gives 20 DEF — damage hits your defense first.", "portrait": ""},
	{"name": "Guide", "text": "Your HP and Defense are shown top-left. Active effects appear bottom-left. If you fall, you may respawn or return to the menu. Good luck!", "portrait": ""}
]

func _ready() -> void:
	esc_panel.visible = false
	esc_popup.visible = false

	$EscMenu/Panel/VBox/ResumeBtn.pressed.connect(_close_menu)
	$EscMenu/Panel/VBox/SettingsBtn.pressed.connect(_on_settings)
	$EscMenu/Panel/VBox/ExitBtn.pressed.connect(_on_exit)

	hud_hint_label.text = "Move: WASD  |  Attack: Left Click  |  Equip/Use: [E]  |  Pause: Esc"

	await get_tree().create_timer(0.4).timeout
	Global.is_dialogue_active = true
	dialogue_ui.start_conversation("Tutorial", TUTORIAL_LINES)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished() -> void:
	Global.is_dialogue_active = false

func _process(_delta: float) -> void:
	if player and is_instance_valid(player):
		hud_weapon_label.text = "Weapon: %s" % ("None" if player.current_weapon == "" else player.current_weapon)

	hp_label.text = "❤ HP:  %d / %d" % [Global.player_hp, Global.MAX_HP]
	def_label.text = "🛡 DEF: %d" % Global.player_defense

	# BUG FIX: Only rebuild effect labels when the effects list actually changes
	if Global.active_effects != _last_effects_snapshot:
		_last_effects_snapshot = Global.active_effects.duplicate()
		_rebuild_effects()

	if Global.player_hp <= 0 and not death_shown:
		death_shown = true
		_show_death_popup()

func _rebuild_effects() -> void:
	for child in effects_container.get_children():
		child.queue_free()
	for effect in Global.active_effects:
		var lbl := Label.new()
		lbl.text = "%s %s" % [effect["icon"], effect["name"]]
		lbl.add_theme_color_override("font_color", effect["color"])
		lbl.add_theme_font_size_override("font_size", 15)
		effects_container.add_child(lbl)

func _show_death_popup() -> void:
	if player:
		player.trigger_death()
	var popup = death_popup_scene.instantiate()
	add_child(popup)
	popup.respawn_requested.connect(_on_respawn)

func _on_respawn() -> void:
	death_shown = false
	if player:
		player.is_dead = false
		player.global_position = Vector2(0, 120)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# BUG FIX: Don't open ESC menu while dialogue is active
		if Global.is_dialogue_active:
			return
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
