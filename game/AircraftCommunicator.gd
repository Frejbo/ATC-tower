extends Node

class_name aircraft_communicator

@onready var body : Node3D = get_parent()
const mover := preload("res://aircraft_mover.tscn")

func _ready() -> void:
	print(await taxi_to_stand(Game.stands.get("20"), ["E", "Y", "F", "L"]))

func taxi_to_stand(stand, route : Array[String]) -> bool:
	route.append(stand.taxiway_in.name)
	return await taxi_to(stand.position, route)

func taxi_to(position : Vector3, route : Array[String]) -> bool:
	var mover_instance = mover.instantiate()
	mover_instance.body = body
	mover_instance.route = route
	mover_instance.goal_position = position
	if await mover_instance.path_is_valid():
		add_child(mover_instance)
		return true
	else:
		return false
