extends CharacterBody2D

var max_hp := 50
var current_hp := 50

@onready var dmg_label: Label = $DMGLabel
@onready var telegraph_area: Area2D = $AttackTelegraph
@onready var telegraph_rect: ColorRect = $AttackTelegraph/ColorRect

const TELEGRAPH_TIME := 0.6
const ATTACK_DAMAGE := 10
const ATTACK_COOLDOWN := 1.5   # seconds between attacks
var attacking := false
# BUG FIX: Guard flag so async_attack() can't stack if queue_free is delayed
var _is_dead := false

func _ready():
	dmg_label.visible = false   # start hidden
	dmg_label.modulate = Color(1,0,0,1)
	dmg_label.z_index = 100
	print("DMGLabel ready:", dmg_label)

	# Start attack loop
	attack_loop()


func take_damage(amount: int, armor_piercing: bool = false):
	# For now, armor_piercing is unused, but kept for future defense logic
	current_hp = max(current_hp - amount, 0)
	print("Enemy took", amount, "damage! HP:", current_hp, "/", max_hp)
	show_damage_number(amount)
	if current_hp <= 0:
		die()

func show_damage_number(amount: int):
	dmg_label.text = str(amount)
	dmg_label.visible = true
	dmg_label.modulate = Color(1,0,0,1)   # full opacity
	dmg_label.z_index = 100
	dmg_label.scale = Vector2(1, 1)       # reset scale

	# Randomize starting position around the enemy
	var rand_x = randi_range(-30, 30)     # random horizontal offset
	var rand_y = randi_range(-60, -20)    # random vertical offset
	dmg_label.position = Vector2(rand_x, rand_y)

	var tween = create_tween()
	# Scale up quickly
	tween.tween_property(dmg_label, "scale", Vector2(5, 5), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Shrink back to normal
	tween.tween_property(dmg_label, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	# Fade out
	tween.tween_property(dmg_label, "modulate:a", 0, 0.5)
	# Hide after animation
	tween.finished.connect(func():
		if is_instance_valid(dmg_label):
			dmg_label.visible = false
			dmg_label.modulate = Color(1,0,0,1) # reset alpha for next hit
	)

func die():
	# BUG FIX: Set _is_dead before queue_free so the async_attack loop stops cleanly
	_is_dead = true
	queue_free()

# --- Attack loop ---
func attack_loop() -> void:
	# Run attacks forever until enemy dies
	async_attack()

func async_attack() -> void:
	# BUG FIX: Guard against continuing the loop after death (queue_free may be deferred)
	if _is_dead or not is_instance_valid(self):
		return

	# Telegraph phase
	attacking = true
	telegraph_area.monitoring = true
	telegraph_rect.visible = true
	telegraph_rect.modulate = Color(1,0,0,0.5)

	await get_tree().create_timer(TELEGRAPH_TIME).timeout

	# BUG FIX: Re-check validity after every await in case ghoul was freed mid-attack
	if _is_dead or not is_instance_valid(self):
		return

	# Strike phase
	for body in telegraph_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(ATTACK_DAMAGE)

	# Reset
	telegraph_area.monitoring = false
	telegraph_rect.visible = false
	attacking = false

	# Cooldown before next attack
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout

	# BUG FIX: Re-check again after cooldown await
	if _is_dead or not is_instance_valid(self):
		return

	# Repeat
	async_attack()
