extends Node2D

const SETTINGS_DATA_PATH = "user://settings.json"

func _ready():
	var settings = get_settings()
	$MusicSlider.value = settings.volume.music
	$EffectsSlider.value = settings.volume.effects
	$MasterSlider.value = settings.volume.master
	update_audio_bus_volumes()

func update_audio_bus_volumes():
	var settings = get_settings()
	AudioServer.set_bus_volume_db(0, linear_to_db(settings.volume.master/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(settings.volume.music/100.0))
	AudioServer.set_bus_volume_db(2, linear_to_db(settings.volume.effects/100.0))

func _on_music_slider_value_changed(value):
	$MusicPercent.text = str(value) + "%"
	save_settings()
	update_audio_bus_volumes()

func _on_effects_slider_value_changed(value):
	$EffectsPercent.text = str(value) + "%"
	save_settings()
	update_audio_bus_volumes()

func _on_master_slider_value_changed(value):
	$MasterPercent.text = str(value) + "%"
	save_settings()
	update_audio_bus_volumes()
	
func save_settings():
	var file = FileAccess.open(SETTINGS_DATA_PATH, FileAccess.WRITE)
	var data = {
		"_v" = 1,
		"volume" = {
		music = $MusicSlider.value,
		effects = $EffectsSlider.value,
		master = $MasterSlider.value,
		}
	}
	file.store_string(JSON.stringify(data))
	print("saved settings ")
	
func get_settings():
	if FileAccess.file_exists(SETTINGS_DATA_PATH):
		var gameData = FileAccess.open(SETTINGS_DATA_PATH, FileAccess.READ)
		var parsed = JSON.parse_string(gameData.get_as_text())
		print("loaded settings ", SETTINGS_DATA_PATH)
		return parsed
	else:
		var file = FileAccess.open(SETTINGS_DATA_PATH, FileAccess.WRITE)
		var data = {
			"_v" = 1,
			"volume" = {
				music = 75,
				effects = 100,
				master = 100,
			}
		}
		file.store_string(JSON.stringify(data))
		print("initialized settings ",SETTINGS_DATA_PATH)
		return data



func _on_back_button_pressed():
	get_node("/root/TitleScreen").visible = true
	visible = false

