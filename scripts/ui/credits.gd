extends Control

@onready var container = $VBoxContainer

func _ready() -> void:
	# Start the text below the bottom of the screen
	container.position.y = get_viewport_rect().size.y + 50
	
	# Create the scrolling animation
	var tween = create_tween()
	
	# Move the text slowly up to the top, off-screen. (Change '15.0' to make it faster/slower)
	tween.tween_property(container, "position:y", -500.0, 15.0)
	
	# When the credits finish rolling, go back to the Main Menu (or quit)
	tween.finished.connect(_on_credits_finished)

func _on_credits_finished() -> void:
	# Swap this out with your actual main menu path when you have one!
	# get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	print("Game Demo Concluded!")
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

# Let the player skip the credits if they want
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_on_credits_finished()
