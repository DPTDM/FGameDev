extends Area2D

# SpearProjectile.gd
# Physical projectile that travels in a straight line and pierces through
# every enemy it contacts without stopping. Pairs well with dash (future).
# Deals physical damage — affected by enemy armor/defense.

const SPEED := 600.0
const DAMAGE := 8
const LIFETIME := 1.5   # seconds before auto-destroy

# Track already-hit targets so we don't double-hit the same enemy
var _hit_targets: Array[Node] = []

var direction := Vector2.RIGHT

func _ready() -> void:
	# Layer 4 = Projectile. Mask 3 = Enemies only (NOT layer 2 = Player).
	# BUG FIX: mask was 2 (Player layer), causing player's own spear to hit themselves.
	collision_layer = 4
	collision_mask = 3
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	if target in _hit_targets:
		return
	# Safety check: never damage the player
	if target.is_in_group("player"):
		return
	if target.has_method("take_damage"):
		_hit_targets.append(target)
		# Physical damage (bypasses_defense = false) — spear is physical, not armor-piercing
		target.take_damage(DAMAGE, false)
	# Does NOT call queue_free — projectile continues through the target (piercing)
