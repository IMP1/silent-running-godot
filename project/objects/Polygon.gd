extends Polygon2D

func _ready():
	var poly := CollisionPolygon2D.new()
	poly.polygon = polygon
	poly.position = position
	get_parent().call_deferred("add_child", poly)
