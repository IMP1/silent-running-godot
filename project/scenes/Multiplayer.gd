extends Control

func _on_CreateServer() -> void:
	$"../HostServer/IP/IpAddress".text = Network.ip_address
	$"../HostServer".visible = true
	Network.create_server()
	visible = false

func _on_JoinServer() -> void:
	$"../JoinServer".visible = true
	visible = false

# TODO: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
