@tool
extends Path3D

class_name taxiway

@export var taxiway_name: String :
	set(text):
		if text == "":
			name = "taxiway"
			taxiway_name = ""
			return
		name = text.to_upper()
		taxiway_name = name
@export var allow_y : bool = false

@export_category("editor")
@export var polygon_shape : PackedVector2Array = [Vector2(-.2, -.2), Vector2(.2, -.2), Vector2(.2, .2), Vector2(-.2, .2)]

var csg_debug_shape : CSGPolygon3D

func _on_curve_changed():
	if !curve: return
	if allow_y: return
	
	# Force y of every point to 0
	for i in range(curve.point_count):
		var point = curve.get_point_position(i)
		if point.y != 0:
			curve.set_point_position(i, Vector3(point.x, 0, point.z))

func _enter_tree():
	for child in get_children():
		if child is CSGPolygon3D:
			child.free()
	
	if Engine.is_editor_hint():
		csg_debug_shape = CSGPolygon3D.new()
		csg_debug_shape.polygon = polygon_shape
		csg_debug_shape.mode = CSGPolygon3D.MODE_PATH
		csg_debug_shape.transparency = .5
		add_child(csg_debug_shape)
		csg_debug_shape.owner = self
		csg_debug_shape.path_node = self.get_path()
