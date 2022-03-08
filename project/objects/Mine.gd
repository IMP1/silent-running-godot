extends KinematicBody2D
class_name Mine

onready var game_scene : Node2D = null

const DROP_OFFSET = Vector2(0, 32)

var active = false

func _ready():
	add_to_group("Mine")

func start():
	$AnimationPlayer.play("Fade")
	var target_position = position + DROP_OFFSET
	$DropTween.interpolate_property(self, "position", position, target_position, 1.0)
	$DropTween.start()
	yield($DropTween, "tween_all_completed")
	active = true
	activate()

func activate():
	pass
