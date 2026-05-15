extends Control

const WEAPONS: Array[Dictionary] = [
	{
		"name": "BATTLE AXE",
		"type": "Melee — Two-Handed",
		"description": "A massive double-headed axe built for raw destructive power. Cleaves through enemy armour and sends foes staggering with every blow. Deals 10 damage per hit and ignores enemy Defense entirely, making it the ideal weapon against heavily armoured targets.",
	},
	{
		"name": "SWORD",
		"type": "Melee — One-Handed",
		"description": "A reliable straight-bladed sword forged for balance and versatility. Favoured across all combat styles for its swift strikes and precise thrusts. Deals 5 physical damage per swing and is effective against unarmoured and lightly armoured foes.",
	},
	{
		"name": "MAGIC STAFF",
		"type": "Magic — Two-Handed",
		"description": "An ancient staff crackling with concentrated arcane energy. Fires magic projectiles that deal 3 damage per hit and bypass enemy Defense entirely. Excels at safe ranged combat and is the only weapon that bypasses armour through magical means.",
	},
	{
		"name": "DAGGERS",
		"type": "Melee — Dual Wield",
		"description": "A pair of lightweight blades held in both hands, designed for speed above all else. Strikes three times in rapid succession with each attack, dealing 2 damage per stab. Pairs exceptionally well with the dashing ability, allowing the wielder to dash in and unleash a flurry before retreating.",
	},
	{
		"name": "SPEAR",
		"type": "Ranged — Two-Handed",
		"description": "A long-reaching weapon that hurls a piercing projectile in a straight line, dealing 8 physical damage to every enemy it passes through. Ideal for hitting backline targets behind groups. Pairs well with the dashing ability for aggressive forward thrusts.",
	},
]

@onready var _cards_container: HBoxContainer = $CardsContainer
@onready var _detail_overlay: PanelContainer  = $DetailOverlay
@onready var _detail_image: TextureRect       = $DetailOverlay/DetailScroll/DetailVBox/DetailTopRow/DetailImage
@onready var _detail_name: Label              = $DetailOverlay/DetailScroll/DetailVBox/DetailTopRow/DetailHeaderVBox/DetailName
@onready var _detail_type: Label              = $DetailOverlay/DetailScroll/DetailVBox/DetailTopRow/DetailHeaderVBox/DetailType
@onready var _detail_desc: Label              = $DetailOverlay/DetailScroll/DetailVBox/DetailDescLabel
@onready var _back_from_detail: Button        = $DetailOverlay/DetailScroll/DetailVBox/BackFromDetail
@onready var _back_button: Button             = $BackButton

var _textures: Array[Texture2D] = []

func _ready() -> void:
	# Cache textures from card image nodes in order matching WEAPONS array
	_textures.append($CardsContainer/CardAxe/VBoxAxe/ImageAxe.texture)
	_textures.append($CardsContainer/CardSword/VBoxSword/ImageSword.texture)
	_textures.append($CardsContainer/CardStaff/VBoxStaff/ImageStaff.texture)
	_textures.append($CardsContainer/CardDaggers/VBoxDaggers/ImageDaggers.texture)
	_textures.append($CardsContainer/CardSpear/VBoxSpear/ImageSpear.texture)

	# Wire all View Info buttons
	$CardsContainer/CardAxe/VBoxAxe/ViewInfoAxe.pressed.connect(_on_view_info.bind(0))
	$CardsContainer/CardSword/VBoxSword/ViewInfoSword.pressed.connect(_on_view_info.bind(1))
	$CardsContainer/CardStaff/VBoxStaff/ViewInfoStaff.pressed.connect(_on_view_info.bind(2))
	$CardsContainer/CardDaggers/VBoxDaggers/ViewInfoDaggers.pressed.connect(_on_view_info.bind(3))
	$CardsContainer/CardSpear/VBoxSpear/ViewInfoSpear.pressed.connect(_on_view_info.bind(4))

	_back_from_detail.pressed.connect(_on_back_from_detail)
	_back_button.pressed.connect(_on_back_pressed)

func _on_view_info(index: int) -> void:
	var w: Dictionary = WEAPONS[index]
	_detail_image.texture = _textures[index]
	_detail_name.text     = w["name"]
	_detail_type.text     = w["type"]
	_detail_desc.text     = w["description"]
	_cards_container.visible = false
	_detail_overlay.visible  = true

func _on_back_from_detail() -> void:
	_detail_overlay.visible  = false
	_cards_container.visible = true

func _on_back_pressed() -> void:
	if _detail_overlay.visible:
		_on_back_from_detail()
	else:
		TransitionScreen.fade_to("res://scenes/menus/PlayMenu.tscn")
