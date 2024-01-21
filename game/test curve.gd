extends Node3D

func _ready() -> void:
	var curve : Curve3D = $Path3D.curve
	var points = curve.tessellate_even_length(2, .2)
	print(points)
	
	for point in points:
		var n = MeshInstance3D.new()
		n.mesh = BoxMesh.new()
		n.mesh.size = Vector3(.1, .1, .1)
		n.position = point
		add_child(n)
