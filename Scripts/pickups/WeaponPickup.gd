extends Area2D

@export var weapon_name: String = "Sword"

@onready var icon_label: Label  = $Icon
@onready var name_label: Label  = $Label
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_display()

func _update_display() -> void:
	if icon_label:
		match weapon_name:
			"Sword":     icon_label.text = "⚔"
			"Staff":     icon_label.text = "✨"
			"BattleAxe": icon_label.text = "🪓"
			"Daggers":   icon_label.text = "🗡"
			"Spear":     icon_label.text = "🔱"
			_:           icon_label.text = "?"
	if name_label:
		match weapon_name:
			"BattleAxe": name_label.text = "BATTLE AXE"
			_:           name_label.text = weapon_name.to_upper()
	if prompt_label:
		prompt_label.visible = false

func get_weapon_name() -> String:
	return weapon_name

func _on_body_entered(body: Node) -> void:
	if body.has_method("equip_weapon"):
		body.nearby_pickup = self
		if prompt_label and not Global.is_dialogue_active:
			prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.has_method("equip_weapon"):
		if body.nearby_pickup == self:
			body.nearby_pickup = null
		if prompt_label:
			prompt_label.visible = false
