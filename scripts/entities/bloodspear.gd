extends Area2D

var speed := 400.0
var direction := Vector2.DOWN
var damage := 15

func _ready() -> void:
	# Delete the spear if it flies off the screen
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	
	# Connect the hitbox
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the spear
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if it hit the player or party members
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free() # Destroy the spear on impact
