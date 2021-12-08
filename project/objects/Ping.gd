extends KinematicBody2D

export var speed = 10
export var bounces = 3

var direction : Vector2 = Vector2.ZERO
var remaining_bounces = 0

onready var game_scene : Node2D = null

func _ready():
	remaining_bounces = bounces

func _process(delta):
	var collision : KinematicCollision2D = move_and_collide(direction * speed)
	if collision:
		print(collision.collider)
		game_scene.rpc("add_sound", position)
		direction = -direction # TODO: Bounce this better (use the surface normal?)
		remaining_bounces -= 1
		if remaining_bounces <= 0:
			queue_free()
