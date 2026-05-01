extends Node

# WindowManager.gd
# Autoload that ensures the game window starts in normal windowed mode
# and allows the player to freely maximize, minimize, or resize at any time.
# The stretch settings (canvas_items + expand) handle scaling automatically.

func _ready() -> void:
	var win := get_window()
	# Ensure the window is in normal windowed mode on startup
	win.mode = Window.MODE_WINDOWED
	# Make sure it is resizable and not borderless
	win.unresizable = false
	win.borderless = false
	# Set a sensible minimum size so UI never collapses
	win.min_size = Vector2i(640, 360)
