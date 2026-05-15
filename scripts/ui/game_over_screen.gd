extends CanvasLayer

func _on_restart_button_pressed() -> void:
	# Unpause the game so the physics engine works again
	get_tree().paused = false 
	# Reload the current map!
	get_tree().reload_current_scene() 
	# Delete the Game Over screen
	queue_free() 

func _on_quit_button_pressed() -> void:
	# Closes the game entirely
	get_tree().quit()
