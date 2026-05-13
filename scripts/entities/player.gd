extends CharacterBody2D

# Movement speeds
const WALK_SPEED := 100.0      # slower default speed
const RUN_SPEED := 150.0       # sprint speed
var speed := WALK_SPEED        # current speed

# Player stats
var max_hp := 100
var current_hp := 100
var swing_cooldown := false

@export var game_over_scene: PackedScene
@onready var health_bar: TextureProgressBar = get_node("../HUD/Health")
@onready var wpnPivot: Marker2D = $WeaponPivot
@onready var wpnSlot: Marker2D = $WeaponPivot/WeaponSlot
@onready var weapon: Sprite2D = $WeaponPivot/WeaponSlot/Weapon
@onready var sword_hitbox: Area2D = $WeaponPivot/WeaponSlot/SwordHitbox

var projectile_scene: PackedScene
var sword_swinging := false
var swing_angle := 0.0
var swing_dir := 1.0
var can_control := true
	
const SWING_SPEED := 8.0
const SWING_ARC := 90.0


func update_weapon() -> void:
	var weapon_textures = {
		"Sword": "res://assets/art/broadsword.png",
		"Axe": "res://assets/art/battle-ax.png",
		"Staff": "res://assets/art/staff.png"
	}

	randomize()
	var keys = weapon_textures.keys()
	var choice = keys[randi() % keys.size()]

	weapon.texture = load(weapon_textures[choice])
	Global.player_specialization = choice   # ✅ correct property
	print("Equipped:", choice)

	match choice:
		"Sword":
			weapon.rotation_degrees = 90
		"Staff":
			weapon.rotation_degrees = 0
		"Axe":
			weapon.rotation_degrees = 45

func _is_staff() -> bool:
	return Global.player_specialization in ["Mage", "Supporter", "Staff"]

func _ready() -> void:
	add_to_group("player")
	update_weapon()
	projectile_scene = load("res://scenes/pickups/StaffProjectile.tscn")
	sword_hitbox.monitoring = false
	sword_hitbox.get_node("CollisionShape2D").disabled = true

	# Initialize health bar
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func _physics_process(delta: float) -> void:
	# --- NEW: Freeze check ---
	# If we lose control or a dialogue is active, stop moving instantly!
	if not can_control or Global.is_dialogue_active:
		velocity = Vector2.ZERO
		move_and_slide() # We still call this so collision resolves, but velocity is 0
		return # This skips the rest of the movement code below!
		
	# Sprint toggle: hold Shift to run
	if Input.is_action_pressed("sprint"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed if direction else velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()
	look_at_mouse()

func _input(event: InputEvent) -> void:
	# --- NEW: Prevent attacking during dialogue ---
	if not can_control or Global.is_dialogue_active:
		return 
		
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		if _is_staff():
			_fire_projectile()
		else:
			_swing_sword()

func _swing_sword() -> void:
	
	if sword_swinging or swing_cooldown:
		return
	sword_swinging = true
	swing_cooldown = true

	sword_hitbox.reset_swing()
	sword_hitbox.set_deferred("monitoring", true)
	sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)

	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	var base_angle = rad_to_deg(mouse_dir.angle())
	var start_angle = base_angle - 90
	var end_angle = start_angle + 180

	wpnPivot.rotation_degrees = start_angle

	var tween = create_tween()
	tween.tween_property(wpnPivot, "rotation_degrees", end_angle, 0.6) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(func():
		sword_swinging = false
		# Reset to idle orientation
		wpnPivot.rotation_degrees = base_angle
		wpnSlot.position = Vector2(32, 0)
		wpnSlot.rotation_degrees = 0
		weapon.rotation_degrees = 90
		sword_hitbox.set_deferred("monitoring", false)
		sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)

		# Cooldown timer
		var cd = Timer.new()
		cd.wait_time = 0.3
		cd.one_shot = true
		add_child(cd)
		cd.start()
		cd.timeout.connect(func(): swing_cooldown = false)
	)

func _fire_projectile() -> void:
	if projectile_scene == null:
		return
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = weapon.global_position
	proj.direction = (get_global_mouse_position() - weapon.global_position).normalized()

func look_at_mouse() -> void:
	wpnPivot.look_at(get_global_mouse_position())
	
	# Check if mouse is to the left of the player
	var is_mouse_left = get_global_mouse_position().x < global_position.x
	
	# Flip the weapon
	weapon.flip_h = is_mouse_left
	
	# Flip the player's body


# --- Health management ---
func take_damage(amount: int) -> void:
	current_hp = max(current_hp - amount, 0)
	health_bar.value = current_hp
	print("HP:", current_hp, "/", max_hp)
	
	if current_hp <= 0:
		die()

func die() -> void:
	print("Player has died!")
	can_control = false 
	
	# Stop everything! (Freezes the boss, the treadmill, and the player)
	get_tree().paused = true 
	
	# Summon the Game Over screen
	if game_over_scene != null:
		var go_screen = game_over_scene.instantiate()
		# Add it to the very top of the game tree so it renders over everything
		get_tree().root.add_child(go_screen)

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	health_bar.value = current_hp
	print("HP:", current_hp, "/", max_hp)


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
