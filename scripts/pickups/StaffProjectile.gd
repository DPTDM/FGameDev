extends Area2D

const SPEED := 500.0
const DAMAGE := 3

var direction := Vector2.RIGHT
var _has_hit := false  # BUG FIX: prevent double-damage from area+body both firing

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_area_entered(area: Area2D) -> void:
	if _has_hit:
		return
	var parent = area.get_parent()
	if parent.has_method("take_damage"):
		_has_hit = true
		parent.take_damage(DAMAGE, true)
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _has_hit:
		return
	if body.has_method("take_damage"):
		_has_hit = true
		body.take_damage(DAMAGE, true)
		queue_free()
