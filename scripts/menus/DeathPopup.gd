extends CanvasLayer

signal respawn_requested
signal menu_requested

func _ready() -> void:
	# BUG FIX: Ensure this node and all children process while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBox/RespawnBtn.pressed.connect(_on_respawn)
	$Panel/VBox/MenuBtn.pressed.connect(_on_menu)
	get_tree().paused = true

func _on_respawn() -> void:
	Global.player_hp = Global.MAX_HP
	Global.player_defense = 0
	Global.active_effects.clear()
	get_tree().paused = false
	respawn_requested.emit()
	queue_free()

func _on_menu() -> void:
	get_tree().paused = false
	Global.player_hp = Global.MAX_HP
	Global.player_defense = 0
	Global.active_effects.clear()
	menu_requested.emit()
	TransitionScreen.fade_to("res://scenes/menus/MainMenu.tscn")
	queue_free()
