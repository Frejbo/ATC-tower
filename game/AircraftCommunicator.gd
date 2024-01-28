extends CanvasLayer

class_name aircraft_communicator

@onready var body : Node3D = get_parent()
@onready var pathfinder_resource := pathfinder.new()

#func _ready() -> void:
	#print(await taxi_to_stand(Game.stands.get("20"), ["E", "Y", "F", "L"]))

func taxi_to_stand(stand, route : Array[String]) -> bool:
	route.append(stand.taxiway_in.name)
	return await taxi_to(stand.position, route)

signal taxi_instruction_recieved
func taxi_to(position : Vector3, route : Array[String]) -> bool:
	pathfinder_resource.route = route
	pathfinder_resource.goal_position = position
	if await pathfinder_resource.path_is_valid():
		taxi_instruction_recieved.emit(await pathfinder_resource.calculate_path())
		return true
	else:
		return false
