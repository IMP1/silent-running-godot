extends "res://objects/Mine.gd"
class_name StunMine

func activate():
	game_scene.rpc("add_sound", position, "stun", 3.0)

func _on_body_entered(body: Node):
	if not active:
		return
	if body.is_in_group("Player") and not body.dead:
		body.rpc("stun")
