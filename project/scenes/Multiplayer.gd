extends Control

var external_ip_address : String = "" setget set_ip_address

func set_ip_address(address):
	external_ip_address = address
	$"../HostServer/IP/IpAddress".text = address

func _on_CreateServer() -> void:
	if external_ip_address != "":
		$"../HostServer/IP/IpAddress".text = external_ip_address
	else:
		$"../HostServer/IP/IpAddress".text = Network.ip_address
	$"../HostServer/Port/Port".text = str(Network.DEFAULT_PORT)
	$"../HostServer".visible = true
	Network.create_server()
	visible = false

func _on_JoinServer() -> void:
	$"../JoinServer".visible = true
	visible = false
