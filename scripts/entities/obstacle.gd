extends Area2D

# This will be dynamically updated by the boss arena!
var speed: float = 400.0 

func _physics_process(delta: float) -> void:
	# Move UP the screen to match the treadmill effect
	global_position.y -= speed * delta
	
	# Memory cleanup: Delete the rock once it safely passes the top of the screen
	if global_position.y < -100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Hurt the player if they trip!
		if body.has_method("take_damage"):
			body.take_damage(2) 
			
		# Optional: Play a crunch sound effect here!
		var arena = get_parent() 
		if arena.has_method("trigger_shake"):
			arena.trigger_shake(6.0, 0.2) 
			print("Screen Shake Triggered by Log!") # Adding a print to verify!
		
		# Break the obstacle on impact
		queue_free()
