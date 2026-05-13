extends Area2D

var speed := 350.0
var direction := Vector2.DOWN
var damage := 20
# --- Attack Variables ---
@export var blood_spear_scene: PackedScene 
@export var fire_rate := 1.5               
var attack_timer := 0.0

func _physics_process(delta: float) -> void:
	# Fly endlessly in the assigned direction
	global_position += direction * speed * delta
	
	# Optional: Make the spear point in the direction it's flying
	rotation = direction.angle() + deg_to_rad(90) 

# --- Signals ---
func _on_body_entered(body: Node2D) -> void:
	# Only hit the player!
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage) 
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
