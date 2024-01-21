extends Node3D

class_name aircraft

@export var goal_marker : Marker3D
@export var taxi_route : Array[String]

func _enter_tree() -> void:
	$aircraftMover.route = taxi_route
	$aircraftMover.goal_position = goal_marker.position
