extends Control

func _ready():
	visible = false

func _on_Resume():
	print("Resuming")
	$"../ClientMenu".visible = false

func _on_Quit():
	pass # Replace with function body.
	# TODO: I guess send to server that this player left
	# TODO: Server can count that as a loss, but maybe there's a difference
	
