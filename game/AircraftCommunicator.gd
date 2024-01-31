extends CanvasLayer

class_name aircraft_communicator

@export var assigned_aircraft : aircraft
@onready var taxi_pathfind : pathfinder

#func _ready() -> void:
	#print(await taxi_to_stand(Game.stands.get("20"), ["E", "Y", "F", "L"]))

func taxi_to_stand(stand, route : Array[String]) -> bool:
	route.append(stand.taxiway_in.name)
	return await taxi_to(stand.position, route)

signal taxi_instruction_recieved(route : Curve3D)
func taxi_to(position : Vector3, route : Array[String]) -> bool:
	taxi_pathfind = pathfinder.new(assigned_aircraft.aircraft_body.nosewheel.global_position, position, route, false)
	if await taxi_pathfind.path_is_valid():
		taxi_instruction_recieved.emit(await taxi_pathfind.calculate_path())
		return true
	else:
		return false
