extends Control

onready var main = $"/root/Main"

func _ready():
	var master_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	var master_percentage = db2linear(master_volume) * 100
	$Audio/Volumes/Master/Slider.value = master_percentage
	var sound_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds"))
	var sound_percentage = db2linear(sound_volume) * 100
	$Audio/Volumes/Sounds/Slider.value = sound_percentage
	var music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	var music_percentage = db2linear(music_volume) * 100
	$Audio/Volumes/Music/Slider.value = music_percentage

func _on_Back():
	main.transition_scene("res://scenes/Title.tscn")

func _on_MasterVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_SoundVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), db)

func _on_MusicVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
