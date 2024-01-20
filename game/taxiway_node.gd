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

@export var default_connection_size : float = 2
@export var connection_sizes : Array[float]:
	set(val):
		connection_sizes = val
		for i in val.size():
			if not has_node(str(i)): return
			var area : Area3D = get_node(str(i))
			var coll : SphereShape3D = area.get_child(0).shape
			coll.radius = val[i]


@export_category("editor")
var width := .1
@export var polygon_shape : PackedVector2Array = [Vector2(-width, -width), Vector2(width, -width), Vector2(width, width), Vector2(-width, width)]

var csg_debug_shape : CSGPolygon3D

func _ready() -> void:
	curve_changed.connect(_on_curve_changed)

func _on_curve_changed() -> void:
	if !curve: return
	if curve.point_count < 2: return
	
	# Force y of every point to 0
	if not allow_y:
		for i in range(curve.point_count):
			var point = curve.get_point_position(i)
			if point.y != 0:
				curve.set_point_position(i, Vector3(point.x, 0, point.z))
	
	update_areas()


func _enter_tree() -> void:
	PhysicsServer3D.set_active(true)
	for child in get_children():
		if child.owner == self:
			child.free()
	
	add_to_group("taxiway")
	
	if Engine.is_editor_hint():
		csg_debug_shape = CSGPolygon3D.new()
		csg_debug_shape.polygon = polygon_shape
		csg_debug_shape.mode = CSGPolygon3D.MODE_PATH
		csg_debug_shape.transparency = .5
		add_child(csg_debug_shape)
		csg_debug_shape.owner = self
		#return
		csg_debug_shape.path_node = ".."

func create_area(pos, area_name : String) -> Area3D:
	var area := Area3D.new()
	add_child(area)
	area.owner = self
	area.name = area_name
	
	var coll := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	if area.name.to_int() < connection_sizes.size():
		shape.set_radius(connection_sizes[area.name.to_int()])
	else:
		shape.set_radius(default_connection_size)
	coll.shape = shape
	area.add_child(coll)
	coll.owner = self
	return area


func update_areas() -> void:
	if !curve: return
	var curve_points : Array[int] = []
	for i in curve.point_count:
		curve_points.append(i)
	
	for node in get_children():
		if not node is Area3D: continue
		
		if node.name.to_int() > curve.point_count -1:
			# Point on curve has been deleted, remove corresponding area.
			node.queue_free()
			continue
		
		if curve_points.has(node.name.to_int()):
			# Area and curve point exists and correlate. In case their positions don't align, fix it.
			node.position = curve.get_point_position(node.name.to_int())
			curve_points.erase(node.name.to_int())
			continue
		
		print("I don't think this should happen ", node.name)
	
	for point in curve_points:
		# Point on curve exists but area wasn't found. Add area.
		create_area(curve.get_point_position(point), str(point))
		connection_sizes.append(default_connection_size)
	
	# set areas export array so we can change size
	var area_count := 0
	for area in get_children():
		if not area is Area3D: continue
		area_count += 1
	while area_count > connection_sizes.size():
		connection_sizes.append(default_connection_size)
	while area_count < connection_sizes.size():
		connection_sizes.pop_back()


## Gets all of the placed points
func get_points() -> Array[Vector3]:
	var points : Array[Vector3] = []
	for i in curve.point_count:
		points.append(curve.get_point_position(i-1))
	return points
