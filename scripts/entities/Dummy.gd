extends StaticBody2D

const MAX_HP := 30

var hp := MAX_HP

@onready var hp_label: Label = $HPLabel
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_update_hp_display()

func take_damage(amount: int, _bypasses_defense: bool = false) -> void:
	hp -= amount
	if hp <= 0:
		hp = MAX_HP
	_update_hp_display()
	_flash()

func _update_hp_display() -> void:
	if hp_label:
		hp_label.text = "HP: %d / %d" % [hp, MAX_HP]

func _flash() -> void:
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.12).timeout
	sprite.modulate = Color(1, 1, 1)
