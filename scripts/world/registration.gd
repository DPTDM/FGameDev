extends CanvasLayer

@onready var name_input: LineEdit = $VBoxContainer/NameInput
@onready var gender_dropdown: OptionButton = $VBoxContainer/GenderManager
@onready var spec_dropdown: OptionButton = $VBoxContainer/SpecManager

func _ready() -> void:
	gender_dropdown.clear()
	gender_dropdown.add_item("Male")
	gender_dropdown.add_item("Female")
	gender_dropdown.add_item("Other")

	spec_dropdown.clear()
	spec_dropdown.add_item("Hunter")
	spec_dropdown.add_item("Mage")
	spec_dropdown.add_item("Fighter")
	spec_dropdown.add_item("Supporter")
	spec_dropdown.add_item("Assassin")

func _on_start_button_pressed() -> void:
	var entered_name: String = name_input.text.strip_edges()
	if entered_name == "":
		print("Receptionist frowns. \"I need a name for the records, recruit.\"")
		return

	Global.player_name = entered_name
	# BUG FIX: Global.gender does not exist; correct property is Global.player_gender
	Global.player_gender = gender_dropdown.get_item_text(gender_dropdown.selected)
	# BUG FIX: Global.specialization does not exist; correct property is Global.player_specialization
	Global.player_specialization = spec_dropdown.get_item_text(spec_dropdown.selected)
	# BUG FIX: Global.story_stage is removed; use GameState.story_stage
	GameState.story_stage = 1
	Global.is_dialogue_active = false

	self.visible = false

	var player = get_tree().current_scene.get_node_or_null("Player")
	if player and player.has_method("update_weapon"):
		player.update_weapon()

	# BUG FIX: hardcoded "/root/GuildHall/DialogueUI" breaks if scene is named differently.
	# Use current_scene.get_node_or_null for robustness.
	var ui = get_tree().current_scene.get_node_or_null("DialogueUI")
	if ui:
		var welcome_msg = [
			{
				"name": "Receptionist",
				"text": "Registration complete, " + Global.player_name + ". Here is your Guild Emblem Badge. May your journey be a worthy one.",
				"portrait": "res://icon.svg"
			}
		]
		# BUG FIX: start_conversation() takes one argument only
		ui.start_conversation(welcome_msg)
