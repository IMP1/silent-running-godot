extends Control

onready var main = $"/root/Main"

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
	$Controls/Brake.text = tr("CONTROL_HINT_BRAKE") % tr(Controls.default_key("move_brake"))
	$Controls/Ping.text = tr("CONTROL_HINT_PING") % tr(Controls.default_key("active_ping"))
	$Controls/SilentRunning.text = tr("CONTROL_HINT_SILENCE") % tr(Controls.default_key("toggle_silent_running"))
	$Controls/Torpedo.text = tr("CONTROL_HINT_TORPEDO") % tr(Controls.default_key("fire_torpedo"))
	$Controls/Mine.text = tr("CONTROL_HINT_MINE") % tr(Controls.default_key("use_secondary"))
	$Controls/MineNext.text = tr("CONTROL_HINT_MINE_NEXT") % tr(Controls.default_key("cycle_secondary_forward"))
	$Controls/MinePrev.text = tr("CONTROL_HINT_MINE_PREV") % tr(Controls.default_key("cycle_secondary_backward"))
	$Controls/Movement/Up.text = tr("CONTROL_HINT_MOVE_UP") % tr(Controls.default_key("move_up"))
	$Controls/Movement/Down.text = tr("CONTROL_HINT_MOVE_DOWN") % tr(Controls.default_key("move_down"))
	$Controls/Movement/Left.text = tr("CONTROL_HINT_MOVE_LEFT") % tr(Controls.default_key("move_left"))
	$Controls/Movement/Right.text = tr("CONTROL_HINT_MOVE_RIGHT") % tr(Controls.default_key("move_right"))

func _on_Resume():
	visible = false

func _on_Quit():
	Screenshake.stop()
	main.transition_scene("res://scenes/Title.tscn")
	# TODO: Close game. Disconnect from server? Back to Lobby

func _on_MasterVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_SoundVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), db)

func _on_MusicVolume_changed(value):
	var db = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
