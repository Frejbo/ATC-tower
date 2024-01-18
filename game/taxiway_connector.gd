extends Resource

class_name taxiway_connector

@export_category("Start")
@export var origin_taxiway : Curve3D:
	set(val):
		origin_taxiway = val
		calculate()
@export var point_idx : int:
	set(val):
		point_idx = val
		calculate()
@export_category("End")
@export var target_taxiway : Curve3D:
	set(val):
		target_taxiway = val
		calculate()

var curve := Curve3D.new()

func calculate() -> void:
	if !origin_taxiway or !target_taxiway:
		return
	curve.clear_points()
	
	curve.add_point(origin_taxiway.get_point_position(point_idx))
	curve.add_point(target_taxiway.get_point_position(get_target_point_idx()))
	
	#if Engine.is_editor_hint():
		#render_debug_shape()

func get_target_point_idx() -> int:
	var pos : Vector3 = origin_taxiway.curve.get_point_position(point_idx)
	return target_taxiway.curve.get_closest_point(pos)

var width := .05
var polygon_shape : PackedVector2Array = [Vector2(-width, -width), Vector2(width, -width), Vector2(width, width), Vector2(-width, width)]
#func render_debug_shape() -> void:
	#var csg_debug_shape = CSGPolygon3D.new()
	#csg_debug_shape.polygon = polygon_shape
	#csg_debug_shape.mode = CSGPolygon3D.MODE_PATH
	#csg_debug_shape.transparency = .5
	#add_child(csg_debug_shape)
	#csg_debug_shape.owner = self
	##return
	#csg_debug_shape.path_node = ".."
