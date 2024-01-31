extends Node3D


func _ready() -> void:
	var points = $taxiway.curve.tessellate()
	
	for p in points:
		var mesh = CSGBox3D.new()
		mesh.size = Vector3(5, 5, 5)
		add_child(mesh)
		mesh.position = p
