@tool
extends Path3D
class_name approach_guidance

#@export var show_approach_path : bool
@export var angle : float = 3.0
@export var start_distance : float = 5
@export var active : bool = false

func _ready() -> void:
	if curve.point_count == 0:
		curve.add_point(Vector3(nm_to_m(start_distance), get_position_at_distance(nm_to_m(start_distance)).y, 0))
		curve.add_point(Vector3.ZERO)
	if active:
		Game.active_approach = self


func nm_to_m(nautical_miles : float) -> float:
	return nautical_miles * 1852
func m_to_nm(meters : float) -> float:
	return meters * 0.000539956803

## Takes distance in meters and returns how many meters above the ground the approach recommends to be at.
func get_position_at_distance(distance : float) -> Vector3:
	var pos := Vector3()
	pos.y = tan(deg_to_rad(angle)) * distance
	pos.x = distance
	return global_position + pos.rotated(Vector3(0, 1, 0), global_rotation.y)
