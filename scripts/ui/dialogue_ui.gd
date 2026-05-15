extends CanvasLayer
signal dialogue_finished

@onready var name_label: Label = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/VBox/NameLabel
@onready var text_label: RichTextLabel = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/VBox/TextLabel
@onready var choice_container: HBoxContainer = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/VBox/ChoiceContainer
@onready var portrait: TextureRect = $DialogueControl/MarginContainer/Panel/Portrait
@onready var next_button: Button = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/NextButton

var dialogue_list: Array = []
var current_line_index: int = 0
var auto_timer: Timer

# --- VN Settings ---
@export var text_speed: float = 0.03
var is_typing: bool = false
var current_text: String = ""

func _ready():
	self.visible = false
	choice_container.visible = false
	next_button.visible = false

	auto_timer = Timer.new()
	auto_timer.wait_time = 1.5   # auto‑advance delay
	auto_timer.one_shot = true
	add_child(auto_timer)
	auto_timer.timeout.connect(_on_auto_advance)

func _input(event: InputEvent) -> void:
	# Allows the player to click to skip typing or advance the text manually like a VN!
	if self.visible and (event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)):
		if is_typing:
			# Skip the typewriter effect
			is_typing = false
			text_label.visible_characters = -1
		elif not choice_container.visible:
			# If text is done and there are no choices on screen, advance to the next line
			auto_timer.stop()
			_on_auto_advance()

func start_conversation(lines: Array):
	print("DEBUG: start_conversation called with", lines.size(), "lines")
	visible = true
	
	# --- NEW: Lock the player! ---
	Global.is_dialogue_active = true 
	
	dialogue_list = lines
	current_line_index = 0
	show_dialogue()

func show_dialogue():
	self.visible = true
	choice_container.visible = false
	next_button.visible = false

	var frame = dialogue_list[current_line_index]
	name_label.text = frame.get("name", "").replace("{player}", Global.player_name)

	# Setup the text for the typewriter effect
	current_text = frame.get("text", "").replace("{player}", Global.player_name)
	text_label.text = current_text
	text_label.visible_characters = 0

	var img_path = frame.get("portrait", "")
	if img_path != "":
		portrait.texture = load(img_path)
		portrait.visible = true
	else:
		portrait.visible = false

	# Start the typing animation
	is_typing = true
	_type_text(frame)

func _type_text(frame: Dictionary):
	# Loop to reveal characters one by one
	while text_label.visible_characters < current_text.length():
		if not is_typing:
			break # Break the loop if the player clicked to skip
		text_label.visible_characters += 1
		await get_tree().create_timer(text_speed).timeout
		
	text_label.visible_characters = -1 # Ensure all text is fully visible
	is_typing = false
	
	# Only show choices or inputs AFTER the text finishes typing!
	_on_typing_finished(frame)

func _on_typing_finished(frame: Dictionary):
	# --- handle input frames ---
	if frame.has("input") and frame["input"] == true:
		choice_container.visible = true
		for child in choice_container.get_children():
			child.queue_free()

		var input = LineEdit.new()
		input.placeholder_text = "Type your identity..."
		input.custom_minimum_size = Vector2(400, 40)
		input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		input.size_flags_vertical = Control.SIZE_FILL
		choice_container.add_child(input)

		var confirm_btn = Button.new()
		confirm_btn.text = "Confirm"
		confirm_btn.pressed.connect(func():
			_on_input_confirmed(input.text))
		choice_container.add_child(confirm_btn)

		input.text_submitted.connect(func(value):
			_on_input_confirmed(value))

	# --- handle choice frames ---
	elif frame.has("choices"):
		choice_container.visible = true
		for child in choice_container.get_children():
			child.queue_free()
		for option in frame["choices"]:
			var btn = Button.new()
			btn.text = option
			btn.pressed.connect(func():
				_on_choice_selected(option))
			choice_container.add_child(btn)

	# --- handle specialization dropdown ---
	elif frame.has("specialization") and frame["specialization"] == true:
		choice_container.visible = true
		for child in choice_container.get_children():
			child.queue_free()

		var dropdown = OptionButton.new()
		dropdown.custom_minimum_size = Vector2(200, 40)
		dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		dropdown.add_item("Hunter")
		dropdown.add_item("Mage")
		dropdown.add_item("Fighter")
		dropdown.add_item("Supporter")
		dropdown.add_item("Assassin")

		choice_container.add_child(dropdown)

		var confirm_btn = Button.new()
		confirm_btn.text = "Confirm"
		confirm_btn.pressed.connect(func():
			_on_specialization_confirmed(dropdown.get_item_text(dropdown.selected)))
		choice_container.add_child(confirm_btn)

	# --- auto advance if no input/choices/specialization ---
	else:
		# It will wait 1.5 seconds, OR the player can click to advance instantly
		auto_timer.start()

func _on_auto_advance():
	current_line_index += 1
	if current_line_index < dialogue_list.size():
		show_dialogue()
	else:
		finish_dialogue()

func finish_dialogue():
	choice_container.visible = false
	self.visible = false
	Global.is_dialogue_active = false
	dialogue_finished.emit()

func _on_choice_selected(option: String):
	print("Player chose: ", option)
	current_line_index += 1
	if current_line_index < dialogue_list.size():
		show_dialogue()
	else:
		finish_dialogue()

func _on_input_confirmed(text: String):
	Global.player_name = text
	print("Player identity set to: ", text)
	current_line_index += 1
	if current_line_index < dialogue_list.size():
		show_dialogue()
	else:
		finish_dialogue()

func _on_specialization_confirmed(choice: String):
	Global.player_specialization = choice
	print("Player specialization set to: ", choice)
	current_line_index += 1
	if current_line_index < dialogue_list.size():
		show_dialogue()
	else:
		finish_dialogue()
