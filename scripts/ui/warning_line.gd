extends ColorRect

func _ready() -> void:
	# Center the rectangle exactly on the boss's position
	position.x -= size.x / 2.0
	
	# Make it flash ominously using a Tween!
	var tween = create_tween().set_loops(4)
	tween.tween_property(self, "color:a", 0.1, 0.1)
	tween.tween_property(self, "color:a", 0.6, 0.1)
	
	# The warning lasts for 0.8 seconds before disappearing
	await get_tree().create_timer(0.8).timeout
	queue_free()
