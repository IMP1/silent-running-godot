extends "res://objects/Mine.gd"

var ready = false

func start():
	yield(get_tree().create_timer(1.0), "timeout")
	ready = true

func _on_body_entered(body: Node):
	if not ready:
		return
	if body.is_in_group("Player"):
		body.rpc("stun")
