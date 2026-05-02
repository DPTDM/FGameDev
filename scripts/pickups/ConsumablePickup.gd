extends Area2D

@export var consumable_type: String = "HealthPotion"

@onready var icon_label: Label = $Icon
@onready var name_label: Label = $NameLabel
@onready var prompt_label: Label = $PromptLabel

var player_nearby: Node = null
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_display()

func _update_display() -> void:
	match consumable_type:
		"HealthPotion":
			if icon_label: icon_label.text = "❤"
			if name_label: name_label.text = "Health Potion\n+15 HP"
		"DefensePotion":
			if icon_label: icon_label.text = "🛡"
			if name_label: name_label.text = "Defense Potion\n+20 DEF"
	if prompt_label:
		prompt_label.visible = false

func _on_body_entered(body: Node) -> void:
	if body.has_method("equip_weapon") or body.is_in_group("player"):
		player_nearby = body
		if prompt_label and not used:
			prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body == player_nearby:
		player_nearby = null
		if prompt_label:
			prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if used or player_nearby == null:
		return
	# BUG FIX: Don't consume input while dialogue is open
	if Global.is_dialogue_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_use()

func _use() -> void:
	used = true
	if prompt_label:
		prompt_label.visible = false
	if icon_label:
		icon_label.text = "✓"
	if name_label:
		name_label.text = "Used!"
	match consumable_type:
		"HealthPotion":
			Global.use_health_potion()
		"DefensePotion":
			Global.use_defense_potion()
	await get_tree().create_timer(8.0).timeout
	used = false
	_update_display()
