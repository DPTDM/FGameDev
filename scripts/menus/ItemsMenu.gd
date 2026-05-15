extends Control

# ItemsMenu.gd
# Six item cards are defined entirely in the scene (ItemsMenu.tscn).
# Pressing "View Info" on any card reveals the DetailOverlay showing
# that item's icon, name, type, and description.
# "← Back to Items" hides the overlay and returns to the card grid.
# Stats/effects are intentionally omitted for now (coming soon label shown).

# Item data — description is the only dynamic field needed per card.
# Name, type, and icon are already set as Label text in the scene.
const ITEMS: Array[Dictionary] = [
	{
		"icon": "🧪",
		"name": "Health Potion",
		"type": "Consumable",
		"description": "A small vial filled with a crimson restorative fluid. Drinking it instantly restores a portion of the user's health. An essential item for any adventurer venturing into dangerous territory.",
	},
	{
		"icon": "⚡",
		"name": "Stamina Elixir",
		"type": "Consumable",
		"description": "A fizzing golden draught that revitalises the drinker's muscles. Useful for Warriors wielding heavy weapons, or any character in prolonged combat who needs to keep their attack chain going.",
	},
	{
		"icon": "☠",
		"name": "Poison Vial",
		"type": "Consumable / Weapon Coat",
		"description": "A dark green flask of concentrated toxin. Can be thrown as a splash grenade or applied to bladed weapons. Enemies afflicted by the poison take continuous damage over several seconds.",
	},
	{
		"icon": "💎",
		"name": "Arcane Crystal",
		"type": "Passive Enhancer",
		"description": "A fragment of crystallised magic energy. Carried in the inventory, it passively amplifies the power of all spell-based attacks. Mages prize these above most other items.",
	},
	{
		"icon": "🌑",
		"name": "Shadow Cloak",
		"type": "Active — Ability Item",
		"description": "A shimmering cloak woven from shadow-silk. Activating it renders the wearer invisible for a short time, allowing them to reposition, escape danger, or set up a devastating backstab.",
	},
	{
		"icon": "🛡",
		"name": "Iron Shield",
		"type": "Equipment — Off-Hand",
		"description": "A sturdy round shield that can deflect incoming attacks when raised. Provides a passive armour bonus simply by being equipped, and an active block that nullifies most physical damage.",
	},
]

# Node references.
@onready var _cards_center: CenterContainer = $CardsCenterContainer
@onready var _detail_overlay: PanelContainer  = $DetailOverlay
@onready var _detail_icon:    Label           = $DetailOverlay/DetailScroll/DetailVBox/DetailTopRow/DetailIcon
@onready var _detail_name:    Label           = $DetailOverlay/DetailScroll/DetailVBox/DetailTopRow/DetailHeaderVBox/DetailName
@onready var _detail_type:    Label           = $DetailOverlay/DetailScroll/DetailVBox/DetailTopRow/DetailHeaderVBox/DetailType
@onready var _detail_desc:    Label           = $DetailOverlay/DetailScroll/DetailVBox/DetailDescLabel
@onready var _back_from_detail: Button        = $DetailOverlay/DetailScroll/DetailVBox/BackFromDetail
@onready var _back_button:    Button          = $BackButton

# Ordered list matching ITEMS array — each entry is the View Info button node path.
const VIEW_INFO_PATHS: Array[String] = [
	"CardsCenterContainer/CardsGrid/CardPotion/VBoxPotion/ViewInfoPotion",
	"CardsCenterContainer/CardsGrid/CardElixir/VBoxElixir/ViewInfoElixir",
	"CardsCenterContainer/CardsGrid/CardVial/VBoxVial/ViewInfoVial",
	"CardsCenterContainer/CardsGrid/CardCrystal/VBoxCrystal/ViewInfoCrystal",
	"CardsCenterContainer/CardsGrid/CardCloak/VBoxCloak/ViewInfoCloak",
	"CardsCenterContainer/CardsGrid/CardShield/VBoxShield/ViewInfoShield",
]


func _ready() -> void:
	for i in range(VIEW_INFO_PATHS.size()):
		get_node(VIEW_INFO_PATHS[i]).pressed.connect(_on_view_info.bind(i))

	_back_from_detail.pressed.connect(_on_back_from_detail)
	_back_button.pressed.connect(_on_back_pressed)


func _on_view_info(index: int) -> void:
	var item: Dictionary = ITEMS[index]

	_detail_icon.text  = item["icon"]
	_detail_name.text  = item["name"]
	_detail_type.text  = item["type"]
	_detail_desc.text  = item["description"]

	_cards_center.visible   = false
	_detail_overlay.visible = true


func _on_back_from_detail() -> void:
	_detail_overlay.visible = false
	_cards_center.visible   = true


func _on_back_pressed() -> void:
	# If detail is open, close it first; otherwise leave the scene.
	if _detail_overlay.visible:
		_on_back_from_detail()
	else:
		SceneTransition.fade_to("res://scenes/menus/PlayMenu.tscn")
