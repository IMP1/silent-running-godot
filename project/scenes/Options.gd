extends Control

const LANGUAGE_CODES = ["en_GB", "en_US", "es"]

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
	var current_language = TranslationServer.get_locale()
	$Gameplay/GameplayOptions/Language/Options.selected = LANGUAGE_CODES.find(current_language)
	$Gameplay/GameplayOptions/Screenshake/Slider.value = Screenshake.global_shake_strength_modifier
	for keybinding in $Keybinding/ScrollContainer/KeybindingOptions.get_children():
		var action_name = keybinding.name
		var button = keybinding.get_node("Button")
		var input_event = InputMap.get_action_list(action_name)[0]
		if input_event is InputEventKey:
			var action_scancode = input_event.scancode
			button.text = OS.get_scancode_string(action_scancode)
		elif input_event is InputEventMouseButton:
			button.text = "Mouse %d" % input_event.button_index
		else:
			button.text = "???"
		button.connect("pressed", self, "on_key_rebinding", [action_name, button])

func on_key_rebinding(action_name, button):
	set_process_input(false)
	$InputPrompt.popup()
	var scancode = yield($InputPrompt, "key_selected")
	change_input_binding(action_name, scancode)
	button.text = OS.get_scancode_string(scancode)
	set_process_input(true)

func _on_Back():
	main.save_settings()
	main.transition_scene("res://scenes/Title.tscn")

func _on_MasterVolume_changed(value: float):
	var db : float = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_SoundVolume_changed(value: float):
	var db : float = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), db)

func _on_MusicVolume_changed(value: float):
	var db : float = linear2db(value / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func _on_Language_selected(index):
	TranslationServer.set_locale(LANGUAGE_CODES[index])

func _on_ScreenshakeStrength_changed(value):
	Screenshake.global_shake_strength_modifier = value

func change_input_binding(action, key_scancode):
	InputMap.action_erase_events(action)
	var new_event = InputEventKey.new()
	new_event.set_scancode(key_scancode)
	InputMap.action_add_event(action, new_event)
