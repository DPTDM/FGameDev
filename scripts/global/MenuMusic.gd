extends Node

# MenuMusic.gd
# Autoload singleton that manages all persistent menu music.
# Lives outside any scene so it keeps playing as menus are swapped.
#
# Registered in project.godot under [autoload]:
#   MenuMusic="*res://scripts/global/MenuMusic.gd"
#
# Public API:
#   MenuMusic.play_main_menu()  — switch to main menu track
#   MenuMusic.play_lobby()      — switch to lobby track
#   MenuMusic.stop()            — stop music entirely (call before entering gameplay)

const MAIN_MENU_TRACK := "res://assets/audio/main_menu_music.mp3"
const LOBBY_TRACK     := "res://assets/audio/lobby_music.mp3"
const FADE_DURATION   := 0.8  # seconds to fade out before switching tracks

var _player: AudioStreamPlayer
var _tween: Tween
var _current_track: String = ""


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	play_main_menu()


# --- Public API ---

func play_main_menu() -> void:
	_switch_to(MAIN_MENU_TRACK)


func play_lobby() -> void:
	_switch_to(LOBBY_TRACK)


func stop() -> void:
	_fade_out()


# --- Internal ---

func _switch_to(path: String) -> void:
	# Do nothing if already playing this track.
	if _current_track == path and _player.playing:
		return

	_current_track = path

	if _player.playing:
		# Fade out current track, then swap and fade in.
		await _fade_out()

	var stream := load(path)
	# Enable looping on the stream at runtime.
	if stream is AudioStreamMP3:
		stream.loop = true

	_player.stream = stream
	_player.volume_db = 0.0
	_player.play()


func _fade_out() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", -80.0, FADE_DURATION)
	await _tween.finished
	_player.stop()
	_player.volume_db = 0.0
