extends CanvasLayer

# TransitionScreen.gd
# Autoload singleton that provides a smooth fade-to-black transition
# between any two scenes.
#
# Register in Project Settings → Autoload:
#   Path: res://scripts/global/TransitionScreen.gd
#   Name: SceneTransition
#
# Usage from any script:
#   TransitionScreen.fade_to("res://scenes/menus/PlayMenu.tscn")
#   TransitionScreen.fade_to("res://scenes/world/guild_hall.tscn", 1.5)

signal transition_finished

const DEFAULT_FADE_DURATION := 0.3  # seconds

var _overlay: ColorRect
var _tween: Tween


func _ready() -> void:
	layer = 100  # Always on top of all other CanvasLayers.

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)


## Fade to black, change scene, then fade back in.
## duration: seconds for each half of the fade (fade-out and fade-in).
func fade_to(scene_path: String, duration: float = DEFAULT_FADE_DURATION) -> void:
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # Block input during transition.

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 1), duration)
	await _tween.finished

	get_tree().change_scene_to_file(scene_path)

	# Give the new scene one frame to load before fading in.
	await get_tree().process_frame

	_tween = create_tween()
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 0), duration)
	await _tween.finished

	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emit_signal("transition_finished")
