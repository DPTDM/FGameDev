extends Control

# Emitted with "Sword" or "Staff"
signal weapon_chosen(weapon_name: String)

func _ready() -> void:
	$Panel/VBox/SwordBtn.pressed.connect(_on_sword)
	$Panel/VBox/StaffBtn.pressed.connect(_on_staff)

func _on_sword() -> void:
	emit_signal("weapon_chosen", "Sword")

func _on_staff() -> void:
	emit_signal("weapon_chosen", "Staff")
