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
	Global.gender = gender_dropdown.get_item_text(gender_dropdown.selected)
	Global.specialization = spec_dropdown.get_item_text(spec_dropdown.selected)
	Global.story_stage = 1
	Global.is_dialogue_active = false

	self.visible = false

	var player = get_tree().current_scene.get_node_or_null("Player")
	if player and player.has_method("update_weapon"):
		player.update_weapon()

	var ui = get_node_or_null("/root/GuildHall/DialogueUI")
	if ui:
		var welcome_msg = [
			{
				"name": "Receptionist",
				"text": "Registration complete, " + Global.player_name + ". Here is your Guild Emblem Badge. May your journey be a worthy one.",
				"portrait": "res://icon.svg"
			}
		]
		ui.start_conversation("Receptionist", welcome_msg)
