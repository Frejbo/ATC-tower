extends Node3D


func _ready() -> void:
	var c : Curve3D = $taxiway.curve 
	var points = c.get_baked_points()
	
	for p in points:
		var mesh = CSGBox3D.new()
		mesh.size = Vector3(5, 5, 5)
		add_child(mesh)
		mesh.position = p
