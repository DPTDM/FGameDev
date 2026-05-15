extends CanvasLayer

func _ready() -> void:
	# BUG FIX: The game-over screen is shown while get_tree().paused = true
	# (set in player.gd die()). Without PROCESS_MODE_ALWAYS, button signals
	# never fire while paused — Restart and Quit buttons are completely dead.
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_button_pressed() -> void:
	# Unpause the game so the physics engine works again
	get_tree().paused = false
	# Reload the current map
	get_tree().reload_current_scene()
	# Delete the Game Over screen
	queue_free()

func _on_quit_button_pressed() -> void:
	# Closes the game entirely
	get_tree().quit()
