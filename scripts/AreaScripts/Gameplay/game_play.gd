extends Node2D

var current_area
@onready var stat_page = $HUD/StatPage

func _ready():
	# Load GuildHall first
	load_area("res://scenes/GameLevels/Areas/guild_hall.tscn", "player_start_entrance")
	stat_page.visible = false

func _input(event):
	if event.is_action_pressed("show_stats"):  # B key bound in Input Map
		print("B key pressed - toggling StatPage")


		stat_page.visible = !stat_page.visible

		if stat_page.visible:
			print("StatPage is now OPEN")
		else:
			print("StatPage is now CLOSED")

func load_area(path: String, entry_group: String = "player_start_entrance"):
	# Clear old area
	for child in $AreaContainer.get_children():
		child.queue_free()
		await child.tree_exited

	# Load new area
	var scene = load(path)
	var instance = scene.instantiate()
	$AreaContainer.add_child(instance)
	current_area = instance

	# Find spawn marker in the new area
	var start = get_tree().get_first_node_in_group(entry_group)
	if start:
		$Player.global_position = start.global_position

	# Camera logic
	var area_camera = instance.get_node_or_null("Camera2D")
	if area_camera:
		area_camera.make_current()
	else:
		$Player.get_node("POV").make_current()
