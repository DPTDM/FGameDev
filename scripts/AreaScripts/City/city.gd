extends Node2D # Or whatever your map root is

@onready var top_left: Marker2D = $Node/TopLeft
@onready var bottom_right: Marker2D = $Node/BottomRight

func _ready() -> void:
	# We use call_deferred to wait exactly one frame. 
	# This guarantees the Transition script has completely finished spawning the Player!
	call_deferred("setup_camera_limits")

func setup_camera_limits() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.has_node("POV"):
		var cam = player.get_node("POV")
		
		# Lock the camera to the exact positions of our markers
		cam.limit_left = int(top_left.global_position.x)
		cam.limit_top = int(top_left.global_position.y)
		cam.limit_right = int(bottom_right.global_position.x)
		cam.limit_bottom = int(bottom_right.global_position.y)
		
		# Optional: Turn on smoothing so hitting the edge of the map feels soft
		cam.position_smoothing_enabled = true
		print("Camera locked! Top limit is set to: ", cam.limit_top)
