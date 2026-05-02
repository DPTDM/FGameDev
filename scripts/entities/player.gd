extends CharacterBody2D

# Movement speeds
const WALK_SPEED := 150.0      # slower default speed
const RUN_SPEED := 300.0       # sprint speed
var speed := WALK_SPEED        # current speed

@onready var wpnPivot: Marker2D = $WeaponPivot
@onready var wpnSlot: Marker2D = $WeaponPivot/WeaponSlot
@onready var weapon: Sprite2D = $WeaponPivot/WeaponSlot/Weapon
@onready var sword_hitbox: Area2D = $WeaponPivot/WeaponSlot/SwordHitbox

var projectile_scene: PackedScene
var sword_swinging := false
var swing_angle := 0.0
var swing_dir := 1.0
const SWING_SPEED := 8.0
const SWING_ARC := 90.0

func update_weapon() -> void:
	match Global.specialization:
		"Hunter":   weapon.texture = load("res://assets/art/broadsword.png")
		"Mage":     weapon.texture = load("res://assets/art/staff.png")
		"Fighter":  weapon.texture = load("res://assets/art/battle-ax.png")
		"Supporter":weapon.texture = load("res://assets/art/staff.png")
		"Assassin": weapon.texture = load("res://assets/art/broadsword.png")
		"Sword":    weapon.texture = load("res://assets/art/broadsword.png")
		"Staff":    weapon.texture = load("res://assets/art/staff.png")

func _is_staff() -> bool:
	return Global.specialization in ["Mage", "Supporter", "Staff"]

func _ready() -> void:
	add_to_group("player")
	update_weapon()
	projectile_scene = load("res://scenes/pickups/StaffProjectile.tscn")
	sword_hitbox.monitoring = false
	sword_hitbox.get_node("CollisionShape2D").disabled = true

func _physics_process(delta: float) -> void:
	# Sprint toggle: hold Shift to run
	if Input.is_action_pressed("sprint"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed if direction else velocity.move_toward(Vector2.ZERO, speed)
	move_and_slide()
	look_at_mouse()

	if sword_swinging:
		swing_angle += swing_dir * SWING_SPEED * delta * 60.0
		wpnSlot.rotation_degrees = swing_angle
		if abs(swing_angle) >= SWING_ARC:
			swing_dir *= -1.0
			if swing_angle < 0.0:
				sword_swinging = false
				swing_angle = 0.0
				wpnSlot.rotation_degrees = 0.0
				sword_hitbox.set_deferred("monitoring", false)
				sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
				sword_hitbox.reset_swing()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		if _is_staff():
			_fire_projectile()
		else:
			_swing_sword()

func _swing_sword() -> void:
	if sword_swinging:
		return
	sword_swinging = true
	swing_angle = 0.0
	swing_dir = 1.0
	wpnSlot.rotation_degrees = 0.0
	sword_hitbox.set_deferred("monitoring", true)
	sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
	sword_hitbox.reset_swing()

func _fire_projectile() -> void:
	if projectile_scene == null:
		return
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = weapon.global_position
	proj.direction = (get_global_mouse_position() - weapon.global_position).normalized()

func look_at_mouse() -> void:
	wpnPivot.look_at(get_global_mouse_position())
	weapon.flip_h = get_global_mouse_position().x < global_position.x
