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

@export_category("Areas")
var area_a : Area3D
@export var A_size : float = 1:
	set(val):
		A_size = val
		area_a.get_child(0).shape.radius = val
var area_b : Area3D
@export var B_size : float = 1:
	set(val):
		B_size = val
		area_b.get_child(0).shape.radius = val



#@export var connect_start : taxiway:

	#set(connection):
		#if not connection.curve:
			#return
		#
		#connect_start = connection
		#
		#curve.add_point(curve.get_point_position(0), Vector3.ZERO, Vector3.ZERO, )

@export var connections : Array[taxiway_connector]
	#set(value):
		#
		#var added_taxiway : taxiway = value.filter(func(i): return connected_to.has(value[i]))[0]
		#connected_to = value
		#print(added_taxiway)
		##curve.get_closest_point(value.curve.get_closest_point(self.global_position))

@export_category("editor")
var width := .1
@export var polygon_shape : PackedVector2Array = [Vector2(-width, -width), Vector2(width, -width), Vector2(width, width), Vector2(-width, width)]

var csg_debug_shape : CSGPolygon3D

func _ready() -> void:
	curve_changed.connect(_on_curve_changed)

func _on_curve_changed() -> void:
	if !curve: return
	
	# Force y of every point to 0
	if not allow_y:
		for i in range(curve.point_count):
			var point = curve.get_point_position(i)
			if point.y != 0:
				curve.set_point_position(i, Vector3(point.x, 0, point.z))
	
	if curve.point_count != 0:
		update_area_position()

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
	
	area_a = create_area("A", A_size)
	area_b = create_area("B", B_size)
	update_area_position()

func create_area(area_name, size) -> Area3D:
	var area := Area3D.new()
	area.name = area_name
	add_child(area)
	area.owner = self
	
	var coll := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.set_radius(size)
	coll.shape = shape
	area.add_child(coll)
	coll.owner = self
	return area

func update_area_position() -> void:
	if !curve: return
	if curve.point_count == 0: return
	
	if area_a:
		area_a.position = curve.get_point_position(0)
		await get_tree().physics_frame
	if area_b:
		area_b.position = curve.get_point_position(curve.point_count-1)
