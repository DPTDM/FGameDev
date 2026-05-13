extends CanvasLayer

@onready var objective_label = $MarginContainer/PanelContainer/VBoxContainer/ObjectiveLabel
@onready var panel = $MarginContainer/PanelContainer

func _process(_delta: float) -> void:
	var current_quest = GameState.active_quest
	
	if current_quest == "":
		panel.hide() 
	else:
		panel.show()
		# This ONLY changes the white text, leaving your gold title untouched!
		objective_label.text = current_quest
