extends Node2D

@onready var parallax_bg: ParallaxBackground = $ParallaxBackground

# This determines how fast the player is "running"
@export var scroll_speed := 400.0 
var is_chasing := true

func _ready() -> void:
	# Optional: You can play a high-energy chase music track here!
	pass

func _process(delta: float) -> void:
	if is_chasing:
		# Scroll the background UP (negative Y) to make characters look like they are running DOWN
		parallax_bg.scroll_offset.y -= scroll_speed * delta

# We will call this when the Manananggal hits 0 HP
func end_chase() -> void:
	is_chasing = false
	print("Chase finished! Transitioning to victory...")
	
	# Create a smooth slow-down effect
	var tween = create_tween()
	tween.tween_property(self, "scroll_speed", 0.0, 2.0).set_trans(Tween.TRANS_SINE)
