extends KinematicBody2D
class_name Torpedo

const MAX_SPEED = 100
const ACCELLERATION = 20
const DAMAGE = 80
const ARMING_DELAY = 0.3

var direction : Vector2 = Vector2.ZERO setget set_direction
var velocity : Vector2 = Vector2.ZERO
var armed : bool = false

onready var game_scene : Node2D = null

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	if new_direction.x < 0:
		$Sprite.scale.x *= -1

func _ready():
	add_to_group("Torpedo")
	armed = false
	$AnimationPlayer.play("Fade")
	yield(get_tree().create_timer(ARMING_DELAY), "timeout")
	armed = true

func _process(delta):
	if velocity.length_squared() > MAX_SPEED * MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	elif velocity.length_squared() < MAX_SPEED * MAX_SPEED:
		velocity += direction * delta * ACCELLERATION
	var collision : KinematicCollision2D = move_and_collide(velocity)
	if collision:
		if collision.collider.is_in_group("Player"):
			if armed:
				collision.collider.rpc("damage", DAMAGE)
			else:
				return
		if collision.collider.is_in_group("Mine"):
			game_scene.rpc("add_sound", position, "impact")
			collision.collider.queue_free()
		explode()
		# TODO: Have AOE damage?

func explode():
	game_scene.rpc("add_sound", position, "impact")
	queue_free()

