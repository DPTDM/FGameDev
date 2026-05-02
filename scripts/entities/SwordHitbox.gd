extends Area2D

# Generic melee hitbox used by Sword, Battle Axe, and Daggers.
# Damage and armor-pierce flag are set by the player script before each swing.

var damage: int = 5
var armor_piercing: bool = false

var _hit_this_swing: Array[Node] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func reset_swing() -> void:
	_hit_this_swing.clear()

func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target in _hit_this_swing:
		return
	if target.has_method("take_damage"):
		_hit_this_swing.append(target)
		# armor_piercing=true means defense is bypassed (used by Battle Axe)
		target.take_damage(damage, armor_piercing)
