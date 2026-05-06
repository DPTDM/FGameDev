extends Area2D

# Generic melee hitbox used by Sword, Battle Axe, and Daggers.
# Damage and armor-pierce flag are set by the player script before each swing.

var damage: int = 5
var armor_piercing: bool = false

var _hit_this_swing: Array[Node] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)   # use body_entered for enemies
	area_entered.connect(_on_area_entered)   # optional if you want area vs area

func reset_swing() -> void:
	_hit_this_swing.clear()

func _on_area_entered(area: Area2D) -> void:
	# optional: handle area vs area collisions
	pass

func _on_body_entered(body: Node2D) -> void:
	print("SwordHitbox overlapped:", body.name)
	if body in _hit_this_swing:
		return
	if body.has_method("take_damage"):
		_hit_this_swing.append(body)
		body.take_damage(damage, armor_piercing)
		print("SwordHitbox hit", body.name, "for", damage, "damage")
