extends Resource
class_name UserSettings

const SETTINGS_FILEPATH = "user://settings.tres"

export(float) var volume_master
export(float) var volume_music
export(float) var volume_sound

export(String) var language_code

export(float) var screenshake_factor

export(Dictionary) var keybindings
