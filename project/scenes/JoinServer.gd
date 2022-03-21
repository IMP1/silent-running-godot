extends Control

onready var ip_address_field = $IP/IpAddress
onready var lobby = $".."

func _ready() -> void:
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _disable_controls():
	$UserName/UserName.editable = false
	$IP/IpAddress.editable = false
	$IP/Connect.disabled = true

func _enable_controls():
	$UserName/UserName.editable = true
	$IP/IpAddress.editable = true
	$IP/Connect.disabled = false

func _connected_to_server() -> void:
	$CurrentState.text = tr("MP_CONNECTED")
	lobby.rpc_id(1, "handshake", $UserName/UserName.text)

func _connection_failed() -> void:
	$CurrentState.text = tr("MP_CONNECTION_FAIL")
	_enable_controls()

func _server_disconnected() -> void:
	$CurrentState.text = tr("MP_DISCONNECTED")
	_enable_controls()

func _on_Connect() -> void:
	_disable_controls()
	if _is_valid_ip(ip_address_field.text):
		Network.join_server(ip_address_field.text)
		$CurrentState.text = tr("MP_CONNECTING")

func _on_Back() -> void:
	Network.disconnect_client()
	$CurrentState.text = ""
	_enable_controls()
	lobby.current_tab = 0

func _is_valid_ip(text: String) -> bool:
	# TODO: Add additional text validation
	return text != ""

func recieved_handshake(server_name):
	if server_name == "":
		server_name = "???"
	$CurrentState.text = tr("MP_CONNECTED_NAME") % server_name
