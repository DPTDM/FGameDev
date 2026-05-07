extends CanvasLayer
signal dialogue_finished

@onready var name_label: Label = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/VBox/NameLabel
@onready var text_label: RichTextLabel = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/VBox/TextLabel
@onready var choice_container: HBoxContainer = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/VBox/ChoiceContainer
@onready var portrait: TextureRect = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/Portrait
@onready var next_button: Button = $DialogueControl/MarginContainer/Panel/ContentMargin/HBox/NextButton

var dialogue_list: Array = []
var current_line_index: int = 0
var auto_timer: Timer

func _ready():
	self.visible = false
	choice_container.visible = false
	next_button.visible = false

	auto_timer = Timer.new()
	auto_timer.wait_time = 1.5   # auto‑advance delay
	auto_timer.one_shot = true
	add_child(auto_timer)
	auto_timer.timeout.connect(_on_auto_advance)

func start_conversation(lines: Array):
	dialogue_list = lines
	current_line_index = 0
	show_dialogue()

func show_dialogue():
	self.visible = true
	choice_container.visible = false
	next_button.visible = false

	var frame = dialogue_list[current_line_index]
	name_label.text = frame.get("name", "").replace("{player}", Global.player_name)
	text_label.text = frame.get("text", "").replace("{player}", Global.player_name)

	var img_path = frame.get("portrait", "")
	if img_path != "":
		portrait.texture = load(img_path)
		portrait.visible = true
	else:
		portrait.visible = false

	# --- NEW: handle input frames ---
	if frame.has("input") and frame["input"] == true:
		choice_container.visible = true
		for child in choice_container.get_children():
			child.queue_free()

		var input = LineEdit.new()
		input.placeholder_text = "Type your identity..."
		
		# Enlarge the typing box
		input.custom_minimum_size = Vector2(400, 40)  # width=400px, height=40px
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
	else:
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
