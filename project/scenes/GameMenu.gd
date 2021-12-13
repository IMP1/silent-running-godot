extends Control

func _ready():
	visible = false
	var master_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	var master_percentage = db2linear(master_volume) * 100
	$Settings/MasterVolume/Slider.value = master_percentage
	var sound_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds"))
	var sound_percentage = db2linear(sound_volume) * 100
	$Settings/SoundVolume/Slider.value = sound_percentage
	var music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	var music_percentage = db2linear(music_volume) * 100
	$Settings/MusicVolume/Slider.value = music_percentage

func _on_Resume():
	visible = false

func _on_Quit():
	# TODO: Close game. Disconnect from server? Back to Lobby
	pass # Replace with function body.

func _on_MasterVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_SoundVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), db)

func _on_MusicVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
