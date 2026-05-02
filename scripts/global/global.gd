extends Node

# ── Player Info ──────────────────────────────────────────────────────────────
var player_name: String = "Hunter"
var gender: String = ""
var specialization: String = ""

# ── Player Stats ─────────────────────────────────────────────────────────────
const MAX_HP: int = 150
var player_hp: int = 150
var player_defense: int = 0   # Absorbs damage before HP; depleted first

# ── Active Status Effects (for HUD display) ───────────────────────────────────
# Each entry: { "name": String, "icon": String, "color": Color }
var active_effects: Array = []

# ── Game State ────────────────────────────────────────────────────────────────
var has_party: bool = false
var difficulty: String = ""
var is_dialogue_active: bool = false
var story_stage: int = 0

# ── Apply damage to player (defense absorbs first) ───────────────────────────
func apply_damage_to_player(amount: int) -> void:
	if player_defense > 0:
		var absorbed = min(player_defense, amount)
		player_defense -= absorbed
		amount -= absorbed
		if player_defense <= 0:
			player_defense = 0
			_remove_effect("Defense")
	player_hp -= amount
	player_hp = max(player_hp, 0)

# ── Consumable: Health Potion (+15 HP, no overcap) ───────────────────────────
func use_health_potion() -> void:
	player_hp = min(player_hp + 15, MAX_HP)
	_add_effect("Health", "❤", Color(0.9, 0.2, 0.2))

# ── Consumable: Defense Potion (+20 Defense) ─────────────────────────────────
func use_defense_potion() -> void:
	player_defense += 20
	_add_effect("Defense", "🛡", Color(0.3, 0.6, 1.0))

# ── Internal effect list helpers ─────────────────────────────────────────────
func _add_effect(effect_name: String, icon: String, color: Color) -> void:
	for e in active_effects:
		if e["name"] == effect_name:
			return
	active_effects.append({"name": effect_name, "icon": icon, "color": color})

func _remove_effect(effect_name: String) -> void:
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i]["name"] == effect_name:
			active_effects.remove_at(i)
