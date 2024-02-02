extends CanvasLayer

class_name aircraft_communicator

@export var body : AircraftController
@onready var taxi_pathfind : pathfinder


func taxi_to_stand(stand, route : Array[String]) -> bool:
	route.append(stand.taxiway_in.name)
	return await taxi_to(stand.position, route)

signal taxi_instruction_recieved(route : Curve3D)
func taxi_to(position : Vector3, route : Array[String]) -> bool:
	taxi_pathfind = pathfinder.new(body.get_steering_wheel().global_position, position, route)
	if await taxi_pathfind.path_is_valid():
		taxi_instruction_recieved.emit(await taxi_pathfind.calculate_path())
		return true
	else:
		return false
