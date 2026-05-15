extends Control

# SettingsMenu.gd
# Handles game settings. Currently supports in-game volume adjustment.
# More settings will be added in the future.

const SETTINGS_SAVE_PATH := "user://settings.cfg"

var settings_config := ConfigFile.new()


func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)

	var slider: HSlider = $CenterContainer/VBoxContainer/VolumeSection/VolumeRow/VolumeSlider
	var volume_label: Label = $CenterContainer/VBoxContainer/VolumeSection/VolumeRow/VolumeValueLabel

	_load_settings()
	slider.value = _get_volume()
	_apply_volume(slider.value)
	volume_label.text = "%d%%" % int(slider.value)

	slider.value_changed.connect(func(val: float) -> void:
		volume_label.text = "%d%%" % int(val)
		_apply_volume(val)
		_save_settings(val)
	)


func _apply_volume(value: float) -> void:
	# Converts 0–100 slider to dB for the Master audio bus.
	var db: float = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)


func _load_settings() -> void:
	if settings_config.load(SETTINGS_SAVE_PATH) != OK:
		# No existing save; use defaults.
		pass


func _get_volume() -> float:
	return settings_config.get_value("audio", "master_volume", 80.0)


func _save_settings(volume: float) -> void:
	settings_config.set_value("audio", "master_volume", volume)
	settings_config.save(SETTINGS_SAVE_PATH)


func _on_back_pressed() -> void:
	TransitionScreen.fade_to("res://scenes/menus/MainMenu.tscn")
