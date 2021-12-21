extends Control

onready var main = $"/root/Main"

func _on_Mutiplayer():
	main.transition_scene("res://scenes/Lobby.tscn")

func _on_Options():
	pass # Replace with function body.

func _on_Credits():
	main.transition_scene("res://scenes/Credits.tscn")

func _on_Quit():
	get_tree().quit(0)

