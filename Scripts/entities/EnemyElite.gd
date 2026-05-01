extends CharacterBody2D

const MAX_HP := 100
const DAMAGE := 10
const HIT_COOLDOWN := 2.5
const CHASE_SPEED := 80.0
const DETECT_RADIUS := 220.0
const STOP_RADIUS := 70.0
const RESPAWN_TIME := 3.0

var hp := MAX_HP
var can_hit := true
var is_dead := false
var spawn_position := Vector2.ZERO

@onready var hp_label: Label = $HPLabel
@onready var sprite: ColorRect = $Sprite
@onready var hit_area: Area2D = $HitArea
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	spawn_position = global_position
	_update_display()
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return
	var player := _get_player()
	if player == null:
		velocity = Vector2.ZERO
		return
	var dist := global_position.distance_to(player.global_position)
	if dist > DETECT_RADIUS:
		velocity = Vector2.ZERO
	elif dist > STOP_RADIUS:
		velocity = (player.global_position - global_position).normalized() * CHASE_SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _on_hit_area_body_entered(body: Node) -> void:
	if is_dead:
		return
	if body.is_in_group("player"):
		if can_hit:
			can_hit = false
			Global.apply_damage_to_player(DAMAGE)
			await get_tree().create_timer(HIT_COOLDOWN).timeout
			can_hit = true

func take_damage(amount: int, _bypasses_defense: bool = false) -> void:
	if is_dead:
		return
	hp -= amount
	_update_display()
	_flash()
	if hp <= 0:
		_die()

func _die() -> void:
	is_dead = true
	hp = 0
	sprite.color = Color(0.15, 0.05, 0.3)
	hp_label.text = "DEAD"
	collision.set_deferred("disabled", true)
	hit_area.set_deferred("monitoring", false)
	velocity = Vector2.ZERO
	await get_tree().create_timer(RESPAWN_TIME).timeout
	_respawn()

func _respawn() -> void:
	is_dead = false
	hp = MAX_HP
	global_position = spawn_position
	sprite.color = Color(0.45, 0.05, 0.75)
	collision.set_deferred("disabled", false)
	hit_area.set_deferred("monitoring", true)
	_update_display()

func _update_display() -> void:
	if hp_label:
		hp_label.text = "HP: %d/%d" % [hp, MAX_HP]

func _flash() -> void:
	sprite.color = Color(0.9, 0.7, 1.0)
	await get_tree().create_timer(0.12).timeout
	if not is_dead:
		sprite.color = Color(0.45, 0.05, 0.75)

func _get_player() -> Node:
	var scene := get_tree().current_scene
	var p := scene.get_node_or_null("TutorialPlayer")
	if p == null:
		p = scene.get_node_or_null("Player")
	return p
