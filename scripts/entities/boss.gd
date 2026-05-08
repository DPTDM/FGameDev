extends CharacterBody2D

@export var spear_scene: PackedScene # Drag BloodSpear.tscn here in the Inspector
@onready var left_point: Marker2D = $LeftWingPoint
@onready var right_point: Marker2D = $RightWingPoint
@onready var attack_timer: Timer = $Timers/AttackTimer

# We need a reference to the player to aim
var player: CharacterBody2D

func _ready() -> void:
	# Find the player in the arena
	player = get_tree().get_first_node_in_group("player")
	attack_timer.timeout.connect(fire_spears)

func _physics_process(delta: float) -> void:
	# Optional: Make her slowly drift left and right at the top of the screen
	# to make her harder to hit!
	pass 

func fire_spears() -> void:
	if not is_instance_valid(player) or spear_scene == null:
		return
		
	# Play her attack animation
	$AnimatedSprite2D.play("attack")
	
	# Spawn Left Spear
	_spawn_single_spear(left_point.global_position)
	
	# Spawn Right Spear
	_spawn_single_spear(right_point.global_position)

func _spawn_single_spear(spawn_pos: Vector2) -> void:
	var spear = spear_scene.instantiate()
	get_parent().add_child(spear) # Add to the main arena, not the boss
	
	spear.global_position = spawn_pos
	
	# Aim directly at the player
	var aim_direction = (player.global_position - spawn_pos).normalized()
	spear.direction = aim_direction
	
	# Rotate the spear sprite to face the direction it is flying
	spear.rotation = aim_direction.angle() + deg_to_rad(90) # Adjust +90 based on how you drew the sprite
