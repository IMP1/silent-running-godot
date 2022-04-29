extends PopupPanel

signal key_selected(scancode)

func _input(event):
	if event is InputEventKey:
		yield(get_tree(), "idle_frame")
		emit_signal("key_selected", event.scancode)
		hide()
