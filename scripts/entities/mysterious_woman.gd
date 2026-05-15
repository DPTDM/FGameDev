extends CharacterBody2D

@export var sprint_speed: float = 70.0 # Make her slightly slower than the player so they can reach the blue trigger!
var current_state = "NPC" # Can be "NPC" or "CHASING"
var player_in_zone = false
var player: CharacterBody2D

# --- NEW: BARRIER VARIABLES ---
@export var village_blocker_shape: CollisionShape2D
@export var boss_exit_shape: CollisionShape2D

@onready var interaction_label = $InteractionLabel
@onready var animated_sprite = $Sprite2D

func _ready() -> void:
	interaction_label.hide()
	player = get_tree().get_first_node_in_group("player")

# --- SIGNAL: Connect this from InteractArea -> body_entered ---
func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and current_state == "NPC":
		player_in_zone = true
		interaction_label.show()

# --- SIGNAL: Connect this from InteractArea -> body_exited ---
func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = false
		interaction_label.hide()

func _input(event: InputEvent) -> void:
	# Don't trigger if dialogue is already open
	var ui = get_node_or_null("/root/GamePlay/DialogueUI")
	if ui and ui.visible:
		return

	if player_in_zone and current_state == "NPC" and event.is_action_pressed("interact"):
		trigger_dialogue_and_chase(ui)

func trigger_dialogue_and_chase(ui) -> void:
	interaction_label.hide()
	
	# The creepy dialogue before the chase
	var reveal_text = [
		{"name": "Mysterious Woman", "text": "Are you lost, Hunter? The temple ruins are awfully cold tonight.", "portrait": "res://icon.svg"},
		{"name": "Mysterious Woman", "text": "You smell different from the villagers... less afraid.", "portrait": "res://icon.svg"},
		{"name": "Mysterious Woman", "text": "But flesh is flesh. And I am so very hungry...", "portrait": "res://icon.svg"}
	]
	
	if ui != null:
		ui.start_conversation(reveal_text)
		await ui.dialogue_finished
	# --- NEW: TRIGGER THE TRAP! ---
	# Turn ON the wall behind them (using set_deferred is the safest way to change physics in Godot)
	if village_blocker_shape:
		village_blocker_shape.set_deferred("disabled", false)
		
	# Turn ON the exit trigger so they can escape
	if boss_exit_shape:
		boss_exit_shape.set_deferred("disabled", false)
	# --- THE CHASE BEGINS ---
	current_state = "CHASING"
	
	# Pro-Tip: If you have a scream or a creepy laugh sound effect, play it right here!
	# $AudioStreamPlayer.play()
	
	# Optional: Turn her completely red to show she is hostile
	modulate = Color(1, 0, 0) 

func _physics_process(delta: float) -> void:
	# Only move if the dialogue is over and the state has changed
	if current_state == "CHASING" and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * sprint_speed
		move_and_slide()
		
		# Flip the sprite to face the player while running
		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0


func _on_kill_area_body_entered(body: Node2D) -> void:
	# Only kill them if she is actively chasing! (So she doesn't kill them while talking)
	if current_state == "CHASING" and body.name == "Player":
		
		# Option A: Deal massive damage (if you have a death animation on your player)
		if body.has_method("take_damage"):
			body.take_damage(9999)
