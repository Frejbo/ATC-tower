@tool
extends Path3D

class_name taxiway

@export var taxiway_name: String :
	set(text):
		taxiway_name = text.to_upper()
@export var allow_y : bool = false

@export_category("editor")
@export var polygon_shape : PackedVector2Array:
	set(shape):
		csg_debug_shape.polygon = shape
	get:
		return polygon_shape

var csg_debug_shape : CSGPolygon3D

func _on_curve_changed():
	print("HEJ")
	#if !curve: return
	if allow_y: return
	
	# Force y of every point to 0
	for i in range(curve.point_count):
		var point = curve.get_point_position(i)
		if point.y != 0:
			curve.set_point_position(i, Vector3(point.x, 0, point.z))

func _enter_tree():
	csg_debug_shape = CSGPolygon3D.new()
	#csg_debug_shape.set_polygon(polygon_shape)
	csg_debug_shape.mode = CSGPolygon3D.MODE_PATH
	csg_debug_shape.path_node = self.get_path()
	add_child(csg_debug_shape)
	
	if !Engine.is_editor_hint():
		print("Removing mesh")
		$CSGPolygon3D.free()
