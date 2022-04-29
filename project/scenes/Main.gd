extends Node

var settings

onready var music_manager = $MusicManager
onready var current_scene = $CurrentScene.get_child(0)

func transition_scene(next_scene_path: String):
	var next_scene = load(next_scene_path).instance()
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(next_scene)
	current_scene = next_scene

func _ready():
	load_settings()

func load_settings():
	settings = load(UserSettings.SETTINGS_FILEPATH)
	if not settings:
		settings = UserSettings.new()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), settings.volume_master)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), settings.volume_sound)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), settings.volume_music)
	TranslationServer.set_locale(settings.language_code)
	Screenshake.global_shake_strength_modifier = settings.screenshake_factor
	for action in settings.keybindings:
		InputMap.action_erase_events(action)
		for input_event in settings.keybindings[action]:
			InputMap.action_add_event(action, input_event)

func save_settings():
	settings.volume_master = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	settings.volume_sound = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds"))
	settings.volume_music = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	settings.language_code = TranslationServer.get_locale()
	settings.screenshake_factor = Screenshake.global_shake_strength_modifier
	settings.keybindings = {}
	for action in InputMap.get_actions():
		settings.keybindings[action] = InputMap.get_action_list(action)
	ResourceSaver.save(UserSettings.SETTINGS_FILEPATH, settings)
	print("saving settings")
