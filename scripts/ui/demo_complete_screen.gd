extends CanvasLayer

func _ready() -> void:
	# BUG FIX: The demo complete screen is shown while get_tree().paused = true
	# (set in boss_fight_scene.gd). Without PROCESS_MODE_ALWAYS, neither _input
	# nor button signals fire while paused, making the Quit button unresponsive.
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_quit_button_pressed() -> void:
	get_tree().quit()
