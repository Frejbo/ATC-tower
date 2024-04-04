@tool
extends Resource

class_name pushback_points
signal updated_points(Array)

@export var points : Array
@export_group("Add new point")
@export var new_rotation : float
@export var new_position : Vector2
@export var add_point_using_rotation_and_position : bool:
	set(val):
		points.append({"position":new_position, "rotation":new_rotation})
		updated_points.emit(points)
		add_point_using_rotation_and_position = false
		print("Added pushback point with position ", new_position, " and rotation ", new_rotation)
