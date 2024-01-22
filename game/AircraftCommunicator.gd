extends Node

class_name aircraft_communicator

@onready var body : Node3D = get_parent()
const mover := preload("res://aircraft_mover.tscn")

func _ready() -> void:
	taxi_to(Vector3(1030, 0, 450), ["E", "Y", "J", "L"])

func taxi_to(position : Vector3, route : Array[String]) -> bool:
	var mover_instance = mover.instantiate()
	print(body)
	print("HAJ")
	mover_instance.body = body
	mover_instance.route = route
	mover_instance.goal_position = position
	if await mover_instance.path_is_valid():
		add_child(mover_instance)
		return true
	else:
		return false
