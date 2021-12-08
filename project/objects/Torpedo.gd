extends KinematicBody2D

const MAX_SPEED = 100
const ACCELLERATION = 20

var direction : Vector2 = Vector2.ZERO setget set_direction
var velocity : Vector2 = Vector2.ZERO

onready var game_scene : Node2D = null

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	if new_direction.x < 0:
		$Sprite.scale.x *= -1

func _process(delta):
	if velocity.length_squared() > MAX_SPEED * MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	elif velocity.length_squared() < MAX_SPEED * MAX_SPEED:
		velocity += direction * delta * ACCELLERATION
	position += velocity * delta
	# TODO: Handle collisions

func _ready():
	$AnimationPlayer.play("Fade")
