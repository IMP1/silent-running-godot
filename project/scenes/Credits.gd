extends Control

const WEBSITE_LINK = "https://imp-1.itch.io/silent-running"

onready var main = $"/root/Main"
var paused

func _ready():
	paused = false
	$ScrollContainer/ScrollContents/Website.text = WEBSITE_LINK

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

func link_pressed():
	OS.shell_open(WEBSITE_LINK)
