extends CharacterBody2D

# ── Weapon stats ──────────────────────────────────────────────────────────────
# Sword      – 5 dmg   | physical | 90°  arc swing
# Battle Axe – 10 dmg  | armor-piercing | 110° arc | 0.8s cooldown
# Daggers    – 2 dmg×3 | physical | dual sprites | rapid 0.12s stabs
# Spear      – 8 dmg   | physical | piercing projectile | tip faces mouse
# Staff      – 3 dmg   | magic (bypasses armor) | projectile
# ─────────────────────────────────────────────────────────────────────────────

const SPEED := 300.0

# ── Right-hand weapon nodes ───────────────────────────────────────────────────
@onready var wpnPivot: Marker2D     = $WeaponPivot
@onready var wpnSlot: Marker2D      = $WeaponPivot/WeaponSlot
@onready var weapon: Sprite2D       = $WeaponPivot/WeaponSlot/Weapon
@onready var sword_hitbox: Area2D   = $WeaponPivot/WeaponSlot/SwordHitbox

# ── Left-hand dagger nodes ────────────────────────────────────────────────────
@onready var wpnSlotLeft: Marker2D      = $WeaponPivot/WeaponSlotLeft
@onready var weaponLeft: Sprite2D       = $WeaponPivot/WeaponSlotLeft/WeaponLeft
@onready var daggerHitboxLeft: Area2D   = $WeaponPivot/WeaponSlotLeft/DaggerHitboxLeft

# ── Projectile scenes ─────────────────────────────────────────────────────────
var staff_scene: PackedScene
var spear_scene: PackedScene

# ── Swing state ───────────────────────────────────────────────────────────────
var sword_swinging := false
var swing_angle := 0.0
var swing_dir := 1.0
const SWING_SPEED := 8.0

const ARC_SWORD  := 90.0
const ARC_AXE    := 110.0
const ARC_DAGGER := 50.0
var current_arc  := ARC_SWORD

# ── Cooldown flags ────────────────────────────────────────────────────────────
var axe_on_cooldown  := false
const AXE_COOLDOWN   := 0.8

var dagger_attacking := false

# ── General state ─────────────────────────────────────────────────────────────
var current_weapon: String = ""
var nearby_pickup: Node    = null
var is_dead := false

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group("player")
	staff_scene = load("res://scenes/pickups/StaffProjectile.tscn")
	spear_scene = load("res://scenes/pickups/SpearProjectile.tscn")
	_disable_hitbox(sword_hitbox)
	_disable_hitbox(daggerHitboxLeft)
	weapon.visible     = false
	weaponLeft.visible = false

# ── Equip ─────────────────────────────────────────────────────────────────────
func equip_weapon(weapon_name: String) -> void:
	current_weapon = weapon_name

	# Reset swing state on every swap
	sword_swinging = false
	swing_angle    = 0.0
	wpnSlot.rotation_degrees     = 0.0
	wpnSlotLeft.rotation_degrees = 0.0
	_disable_hitbox(sword_hitbox)
	_disable_hitbox(daggerHitboxLeft)
	sword_hitbox.reset_swing()
	daggerHitboxLeft.reset_swing()

	# Hide both sprites first, then show what's needed
	weapon.visible     = false
	weaponLeft.visible = false
	weapon.rotation    = 0.0
	weaponLeft.rotation = 0.0

	match weapon_name:
		"Sword":
			weapon.texture = load("res://assets/weapons/broadsword.png")
			weapon.scale   = Vector2(0.4, 0.4)
			weapon.visible = true

		"Staff":
			weapon.texture = load("res://assets/weapons/magic_staff.png")
			weapon.scale   = Vector2(0.4, 0.4)
			weapon.visible = true

		"BattleAxe":
			weapon.texture = load("res://assets/weapons/battle-axe.png")
			weapon.scale   = Vector2(0.5, 0.5)
			weapon.visible = true

		"Daggers":
			var dtex: Texture2D = load("res://assets/weapons/dagger.png")
			# Right dagger — normal orientation
			weapon.texture  = dtex
			weapon.scale    = Vector2(0.17, 0.17)
			weapon.rotation = 0.0
			weapon.visible  = true
			# Left dagger — flipped horizontally to mirror left hand
			weaponLeft.texture  = dtex
			weaponLeft.scale    = Vector2(0.17, 0.17)
			weaponLeft.flip_h   = true
			weaponLeft.visible  = true

		"Spear":
			weapon.texture  = load("res://assets/weapons/spear.png")
			weapon.scale    = Vector2(0.45, 0.45)
			# Sprite is vertical (tip up). Rotate -90° so tip points RIGHT
			# to match WeaponPivot's default facing direction.
			weapon.rotation = PI / 2.0
			weapon.visible  = true

# ── Physics ───────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED if direction else velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()
	_look_at_mouse()

	if sword_swinging:
		swing_angle += swing_dir * SWING_SPEED * delta * 60.0
		wpnSlot.rotation_degrees     = swing_angle
		wpnSlotLeft.rotation_degrees = swing_angle
		if abs(swing_angle) >= current_arc:
			swing_dir *= -1.0
			if swing_angle < 0.0:
				sword_swinging = false
				swing_angle    = 0.0
				wpnSlot.rotation_degrees     = 0.0
				wpnSlotLeft.rotation_degrees = 0.0
				_disable_hitbox(sword_hitbox)
				_disable_hitbox(daggerHitboxLeft)
				sword_hitbox.reset_swing()
				daggerHitboxLeft.reset_swing()

# ── Input ─────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if is_dead or Global.is_dialogue_active:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if nearby_pickup != null and nearby_pickup.has_method("get_weapon_name"):
				equip_weapon(nearby_pickup.get_weapon_name())

	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		if current_weapon == "":
			return
		match current_weapon:
			"Sword":     _swing_melee(5,  false, ARC_SWORD)
			"BattleAxe": _attack_axe()
			"Daggers":   _attack_daggers()
			"Spear":     _fire_spear()
			"Staff":     _fire_staff()

# ── Melee helpers ─────────────────────────────────────────────────────────────
func _swing_melee(dmg: int, piercing: bool, arc: float) -> void:
	if sword_swinging:
		return
	sword_hitbox.damage        = dmg
	sword_hitbox.armor_piercing = piercing
	current_arc    = arc
	sword_swinging = true
	swing_angle    = 0.0
	swing_dir      = 1.0
	wpnSlot.rotation_degrees = 0.0
	_enable_hitbox(sword_hitbox)
	sword_hitbox.reset_swing()

func _attack_axe() -> void:
	if axe_on_cooldown or sword_swinging:
		return
	axe_on_cooldown = true
	_swing_melee(10, true, ARC_AXE)
	await get_tree().create_timer(AXE_COOLDOWN).timeout
	axe_on_cooldown = false

func _attack_daggers() -> void:
	if dagger_attacking:
		return
	dagger_attacking = true
	for i in range(3):
		if not is_dead:
			sword_hitbox.damage         = 2
			sword_hitbox.armor_piercing = false
			daggerHitboxLeft.damage         = 2
			daggerHitboxLeft.armor_piercing = false
			current_arc    = ARC_DAGGER
			sword_swinging = true
			swing_angle    = 0.0
			swing_dir      = 1.0
			wpnSlot.rotation_degrees     = 0.0
			wpnSlotLeft.rotation_degrees = 0.0
			_enable_hitbox(sword_hitbox)
			_enable_hitbox(daggerHitboxLeft)
			sword_hitbox.reset_swing()
			daggerHitboxLeft.reset_swing()
			await get_tree().create_timer(0.12).timeout
	dagger_attacking = false

# ── Projectile helpers ────────────────────────────────────────────────────────
func _fire_spear() -> void:
	if spear_scene == null:
		return
	var proj := spear_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = weapon.global_position
	var dir := (get_global_mouse_position() - weapon.global_position).normalized()
	proj.direction = dir
	# Rotate projectile visual so the sprite tip points along travel direction
	proj.rotation  = dir.angle()

func _fire_staff() -> void:
	if staff_scene == null:
		return
	var proj := staff_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = weapon.global_position
	proj.direction = (get_global_mouse_position() - weapon.global_position).normalized()

# ── Utility ───────────────────────────────────────────────────────────────────
func _look_at_mouse() -> void:
	wpnPivot.look_at(get_global_mouse_position())
	var facing_left := get_global_mouse_position().x < global_position.x
	weapon.flip_h     = facing_left
	# Left dagger is already flip_h = true; toggle it back when facing right
	if current_weapon == "Daggers":
		weaponLeft.flip_h = not facing_left

func _enable_hitbox(hb: Area2D) -> void:
	hb.set_deferred("monitoring", true)
	hb.get_node("CollisionShape2D").set_deferred("disabled", false)

func _disable_hitbox(hb: Area2D) -> void:
	hb.set_deferred("monitoring", false)
	hb.get_node("CollisionShape2D").set_deferred("disabled", true)

func trigger_death() -> void:
	is_dead = true
