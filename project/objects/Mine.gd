extends KinematicBody2D

onready var game_scene : Node2D = null

func _ready():
	add_to_group("Mine")
	$AnimationPlayer.play("Fade")

func start():
	pass
