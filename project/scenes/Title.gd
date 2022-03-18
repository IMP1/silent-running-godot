extends Control

onready var main = $"/root/Main"

const BACKGROUND_MUSIC = preload("res://audio/mystique.ogg")

func _ready():
	yield(get_tree(), "idle_frame")
	main.music_manager.cross_fade_to(BACKGROUND_MUSIC, 2.0)

func _on_Mutiplayer():
	main.transition_scene("res://scenes/Lobby.tscn")

func _on_Options():
	pass # Replace with function body.

func _on_Credits():
	main.transition_scene("res://scenes/Credits.tscn")

func _on_Quit():
	get_tree().quit(0)

