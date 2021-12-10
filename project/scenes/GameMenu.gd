extends Control

func _ready():
	visible = false

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
