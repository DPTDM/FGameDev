extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var dialogue_ui = $DialogueUI

func _ready():
	# Play cutscene animation first
	anim.play("intro")

	# Connect animation end to dialogue start
	anim.animation_finished.connect(_on_animation_finished)

	# Connect dialogue end to scene transition
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

func _on_animation_finished(anim_name: String):
	if anim_name == "intro":
		# Start dialogue sequence only after intro animation
		dialogue_ui.start_conversation([
			{"name": "Narrator", "text": "As they settle into their seats, introductions continue.", "portrait": ""},
			{"name": "Althea", "text": "My full name is Althea Niel H. Capule. My main profession is a supporter. I have a few spells to help you later—like [Heal] and [Haste]!", "portrait": "res://assets/art/Characters/althea/rotations/south.png"},
			{"name": "Ashton", "text": "Great. Me and {player} will keep you safe in the back so you can focus on supporting us.", "portrait": "res://assets/art/Characters/ashton/rotations/south.png"},
			{"name": "{player}", "text": "(You nod, making Althea brighten up even more.)", "portrait": ""},
			{"name": "Ashton", "text": "Now, it’s my turn! As I’ve said, my name is Ashton Anton P. Montero! I will be our frontline! I won’t let any enemy attack you! I have [Taunt] with me, so no need to panic if one or two get past!", "portrait": "res://assets/art/Characters/ashton/rotations/south.png"},
			{"name": "Althea", "text": "Wow!", "portrait": "res://assets/art/Characters/althea/rotations/south.png"},
			{"name": "System", "text": "How will you respond?", "portrait": "", "choices": ["Dependable", "Stay silent; just nod", "Great!"]},
			{"name": "Narrator", "text": "The three share small talk as the train speeds toward Beringan.", "portrait": ""},
			{"name": "System", "text": "Both Althea and Ashton glance at you, waiting expectantly for your introduction.", "portrait": ""},
			{"name": "System", "text": "(It does not matter what you type; this is your chance to define your identity.)", "portrait": "", "input": true}
		])

func _on_dialogue_finished():
	# Reference the Gameplay scene (the permanent root)
	var gameplay = get_tree().current_scene

	# Load the next area and move player to the marker group
	gameplay.load_area("res://scenes/GameLevels/Areas/sitiodihsembr.tscn", "sitio_village_entrance")
