extends Node

const MOUSE_BUTTON_NAMES = {
	1: "MOUSE_LEFT",
	2: "MOUSE_RIGHT",
	3: "MOUSE_MIDDLE",
	4: "MOUSE_WHEEL_UP",
	5: "MOUSE_WHEEL_DOWN",
	6: "MOUSE_WHEEL_LEFT",
	7: "MOUSE_WHEEL_RIGHT",
}

var controls = {}

func save_to_file(filepath: String) -> void:
	pass

func load_from_file(filepath: String) -> void:
	pass

func default_key(action_name: String) -> String:
	var default_input_event = InputMap.get_action_list(action_name)[0]
	if default_input_event is InputEventMouseButton:
		return MOUSE_BUTTON_NAMES[default_input_event.button_index]
	else:
		return default_input_event.as_text()
