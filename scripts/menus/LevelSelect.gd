extends Control

var _jersey_font := load("res://fonts/Jersey15.tres")

# LevelSelect.gd
# Dynamically builds level buttons for the selected world.
# Level 1 is always unlocked. Subsequent levels unlock once the previous
# level's objectives are completed (tracked in GameState).
#
# To mark a level as complete from gameplay call:
#   GameState.set_level_complete(world_index, level_index)

const WORLD_NAMES := ["VERDANT FOREST", "ASHEN DESERT", "SHADOWKEEP"]
const LEVELS_PER_WORLD := 6  # Adjust as needed.

# Level data per world — extend as the game grows.
const LEVEL_NAMES: Array[Array] = [
	["The First Grove", "Goblin Hollow", "Spider Lair", "Ancient Ruins", "The Dark Root", "Heart of the Forest"],
	["Dune Crossing", "Bandit Camp", "Mirage Temple", "Scorpion Wastes", "Buried Vault", "Eye of the Storm"],
	["Outer Walls", "Haunted Barracks", "The Catacombs", "Throne Antechamber", "Shadow Altar", "Final Darkness"],
]

var world_index: int = 0


func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)

	# Read world from GameState if available.
	if Engine.has_singleton("GameState"):
		world_index = Engine.get_singleton("GameState").selected_world

	$WorldNameLabel.text = "World: %s" % WORLD_NAMES[world_index]
	_build_level_buttons()


func _build_level_buttons() -> void:
	var grid: GridContainer = $ScrollContainer/LevelGrid

	# Clear any previous children.
	for child in grid.get_children():
		child.queue_free()

	var unlocked_count: int = _get_unlocked_level_count()

	for i in range(LEVELS_PER_WORLD):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(160, 140)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)
		panel.add_child(vbox)

		var num_label := Label.new()
		num_label.text = "LEVEL %d" % (i + 1)
		num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_label.add_theme_font_size_override("font_size", 14)
		num_label.add_theme_font_override("font", _jersey_font)
		num_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3, 1))
		vbox.add_child(num_label)

		var name_label := Label.new()
		name_label.text = LEVEL_NAMES[world_index][i]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.add_theme_font_override("font", _jersey_font)
		name_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8, 1))
		vbox.add_child(name_label)

		var is_unlocked: bool = (i < unlocked_count)

		if is_unlocked:
			var play_btn := Button.new()
			play_btn.text = "▶ Play"
			play_btn.add_theme_font_size_override("font_size", 15)
			play_btn.add_theme_font_override("font", _jersey_font)
			play_btn.pressed.connect(_on_level_selected.bind(i))
			vbox.add_child(play_btn)
		else:
			var lock_label := Label.new()
			lock_label.text = "🔒 Locked"
			lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock_label.add_theme_font_size_override("font_size", 14)
			lock_label.add_theme_font_override("font", _jersey_font)
			lock_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5, 1))
			vbox.add_child(lock_label)

			var req_label := Label.new()
			req_label.text = "Complete Level %d" % i
			req_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			req_label.add_theme_font_size_override("font_size", 11)
			req_label.add_theme_font_override("font", _jersey_font)
			req_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 1))
			vbox.add_child(req_label)

			panel.modulate = Color(0.5, 0.5, 0.5, 0.7)

		grid.add_child(panel)


func _get_unlocked_level_count() -> int:
	# First level is always unlocked.
	if not Engine.has_singleton("GameState"):
		return 1
	var gs = Engine.get_singleton("GameState")
	var count: int = 1
	for i in range(LEVELS_PER_WORLD - 1):
		if gs.is_level_complete(world_index, i):
			count += 1
		else:
			break
	return count


func _on_level_selected(level_index: int) -> void:
	if Engine.has_singleton("GameState"):
		Engine.get_singleton("GameState").selected_level = level_index
	# Change to the actual gameplay scene here.
	# SceneTransition.fade_to("res://scenes/GameLevel.tscn")
	print("Starting World %d — Level %d" % [world_index + 1, level_index + 1])


func _on_back_pressed() -> void:
	SceneTransition.fade_to("res://scenes/menus/WorldSelect.tscn")
