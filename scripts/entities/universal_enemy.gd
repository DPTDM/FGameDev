extends CharacterBody2D

# --- UNIVERSAL INSPECTOR VARIABLES ---
@export_category("Enemy Stats")
@export var enemy_name: String = "Enemy"
@export var max_health: int = 10
@export var movement_speed: float = 80.0
@export var attack_damage: int = 5

@export_category("AI Ranges")
@export var detection_range: float = 100.0  # How close player must be to trigger chase
@export var attack_range: float = 25.0      # How close to actually land a hit
@export var attack_cooldown: float = 1.5    # Seconds between attacks

# --- INTERNAL VARIABLES ---
var current_health: int
var player: CharacterBody2D
var is_attacking: bool = false
var can_attack: bool = true
# BUG FIX: Guard flag to prevent use-after-free when queue_free is deferred
var _is_dead: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var dmg_label = $DMGLabel
var attack_timer: Timer

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

	# Create a timer via code so we don't have to add it manually to every scene
	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_cooldown_finished)

	dmg_label.visible = false  # hide until first hit

func _physics_process(_delta: float) -> void:
	# If dead, attacking, or player is missing, stand still
	if _is_dead or is_attacking or not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	# STATE MACHINE: Decide what to do based on distance
	if distance_to_player <= attack_range:
		start_attack()
	elif distance_to_player <= detection_range:
		chase_player()
	else:
		velocity = Vector2.ZERO  # Stand still / Idle

	move_and_slide()

func chase_player() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * movement_speed

	# Flip the sprite to face the player
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

func start_attack() -> void:
	if not can_attack:
		velocity = Vector2.ZERO  # Stop moving while waiting for cooldown
		return

	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO  # Stop in place to attack

	# Deal damage to the player
	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)

	# Wait for attack animation to finish
	await get_tree().create_timer(0.5).timeout

	# BUG FIX: Don't continue if the node was freed during the await
	if _is_dead or not is_instance_valid(self):
		return

	is_attacking = false
	attack_timer.start()  # Start cooldown before next attack

func _on_attack_cooldown_finished() -> void:
	can_attack = true

# --- HOOK THIS TO YOUR HURTBOX ---
# Called when a weapon area (e.g. SwordHitbox) enters this enemy's HurtBox.
# Reads damage and armor_piercing from the area if available (see SwordHitbox.gd).
func _on_hurt_box_area_entered(area: Area2D) -> void:
	var dmg: int = area.damage if area.get("damage") != null else attack_damage
	var ap: bool = area.armor_piercing if area.get("armor_piercing") != null else false
	take_damage(dmg, ap)

func take_damage(amount: int, armor_piercing: bool = false) -> void:
	if _is_dead:
		return
	current_health -= amount
	show_damage_number(amount)
	print("Enemy took ", amount, " damage! Health left: ", current_health)
	if current_health <= 0:
		die()

func die() -> void:
	_is_dead = true
	# Add death effects or loot drops here
	queue_free()

func show_damage_number(amount: int) -> void:
	if not is_instance_valid(dmg_label):
		return
	dmg_label.text = str(amount)
	dmg_label.visible = true
	dmg_label.modulate = Color(1, 0, 0, 1)
	dmg_label.z_index = 100
	dmg_label.scale = Vector2(1, 1)

	var rand_x = randi_range(-30, 30)
	var rand_y = randi_range(-60, -20)
	dmg_label.position = Vector2(rand_x, rand_y)

	var tween = create_tween()
	tween.tween_property(dmg_label, "scale", Vector2(5, 5), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(dmg_label, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(dmg_label, "modulate:a", 0, 0.5)
	tween.finished.connect(func():
		if is_instance_valid(dmg_label):
			dmg_label.visible = false
			dmg_label.modulate = Color(1, 0, 0, 1)
	)
