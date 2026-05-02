extends Node

# GameState.gd
# Global autoload singleton that persists player choices and progress
# across all scenes. Register this in:
#   Project Settings → Autoload → Add GameState.gd with name "GameState"

# ─── Current selections ──────────────────────────────────────────────────────

## Index into CHARACTER_NAMES in CharacterSelect.gd (0–3).
var selected_character: int = -1

## Index into WORLD_NAMES in WorldSelect.gd (0–2).
var selected_world: int = 0

## Index of the chosen level within the current world (0-based).
var selected_level: int = 0

# ─── Level completion tracking ───────────────────────────────────────────────
# Structure: { world_index: { level_index: true/false } }

var _level_completion: Dictionary = {}


func is_level_complete(world_index: int, level_index: int) -> bool:
	if not _level_completion.has(world_index):
		return false
	return _level_completion[world_index].get(level_index, false)


func set_level_complete(world_index: int, level_index: int) -> void:
	if not _level_completion.has(world_index):
		_level_completion[world_index] = {}
	_level_completion[world_index][level_index] = true
	_save_progress()


# ─── Persistence ─────────────────────────────────────────────────────────────

const SAVE_PATH := "user://game_progress.cfg"
var _config := ConfigFile.new()


func _ready() -> void:
	_load_progress()


func _load_progress() -> void:
	if _config.load(SAVE_PATH) != OK:
		return
	var raw = _config.get_value("progress", "level_completion", {})
	_level_completion = raw


func _save_progress() -> void:
	_config.set_value("progress", "level_completion", _level_completion)
	_config.save(SAVE_PATH)
