extends CharacterBody2D

# --- UNIVERSAL INSPECTOR VARIABLES ---
@export_category("Enemy Stats")
@export var enemy_name: String = "Ghoul"
@export var max_health: int = 100
@export var movement_speed: float = 60.0
@export var attack_damage: int = 15

@export_category("AI Ranges")
@export var detection_range: float = 250.0 # How close player must be to trigger chase
@export var attack_range: float = 50.0     # How close to actually land a hit
@export var attack_cooldown: float = 1.5   # Seconds between attacks

# --- INTERNAL VARIABLES ---
var current_health: int
var player: CharacterBody2D
var is_attacking: bool = false
var can_attack: bool = true

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

func _physics_process(_delta: float) -> void:
	# If we are currently attacking or the player is missing, stand still
	if is_attacking or not player:
		return

	# Calculate the distance to the player
	var distance_to_player = global_position.distance_to(player.global_position)

	# STATE MACHINE: Decide what to do based on distance
	if distance_to_player <= attack_range:
		start_attack()
	elif distance_to_player <= detection_range:
		chase_player()
	else:
		velocity = Vector2.ZERO # Stand still/Idle

	move_and_slide()

func chase_player() -> void:
	# Find the direction towards the player and move
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * movement_speed
	
	# Flip the sprite to face the player
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

func start_attack() -> void:
	if not can_attack:
		velocity = Vector2.ZERO # Stop moving while waiting for cooldown
		return
		
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO # Stop in place to attack
	
	# Optional: Play an attack animation here if you have one
	# animated_sprite.play("attack")
	
	# Deal damage to the player
	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
		
	# Wait for a brief moment (simulating the attack animation finishing)
	await get_tree().create_timer(0.5).timeout
	
	is_attacking = false
	attack_timer.start() # Start the cooldown until they can hit again

func _on_attack_cooldown_finished() -> void:
	can_attack = true

# --- HOOK THIS TO YOUR HURTBOX ---
# --- HOOK THIS TO YOUR HURTBOX ---
func take_damage(amount: int, armor_piercing: bool = false) -> void:
	current_health -= amount
	
	# THIS IS THE MISSING LINE! Call the text display function:
	show_damage_number(amount)
	
	print("Enemy took ", amount, " damage! Health left: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	# Add any death effects or loot drops here
	queue_free()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	take_damage(5, true)
	
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
		dmg_label.visible = false
		dmg_label.modulate = Color(1,0,0,1) # reset alpha for next hit
	)
