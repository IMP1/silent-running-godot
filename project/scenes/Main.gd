extends Node

func transition_scene(next_scene_path: String):
	var next_scene = load(next_scene_path).instance()
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(next_scene)
