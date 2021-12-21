extends Control

onready var main = $"/root/Main"
var paused

func _ready():
	paused = false

func _input(event):
	if event.is_action_pressed("ui_select"):
		paused = not paused

func _process(delta):
	if not paused:
		$ScrollContainer.scroll_vertical += 1

func _on_Back():
	main.transition_scene("res://scenes/Title.tscn")

func _on_scroll_started():
	paused = true

func _on_scroll_ended():
	paused = false
