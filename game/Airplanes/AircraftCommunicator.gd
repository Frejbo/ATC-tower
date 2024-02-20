extends CanvasLayer

class_name aircraft_communicator

@export var body : AircraftController
@export var aircraft : Aircraft
@onready var taxi_pathfind : pathfinder


func taxi_to_stand(stand : Marker3D, route : Array[String]) -> bool:
	route.append(stand.taxiway_in.name)
	
	var chatMessage := aircraft.callsign + " taxi to stand " + stand.name + " via "
	var vias = route
	vias.pop_back()
	for s : String in vias:
		chatMessage += s + ", "
	chatMessage = chatMessage.left(-2)
	chatMessage += "."
	Game.chat.send_tower_message(chatMessage)
	return await taxi_to(stand.position, route)

signal taxi_instruction_recieved(route : Curve3D)
func taxi_to(position : Vector3, route : Array[String]) -> bool:
	taxi_pathfind = pathfinder.new(body.get_steering_wheel().global_position, position, route)
	if await taxi_pathfind.path_is_valid():
		taxi_instruction_recieved.emit(await taxi_pathfind.calculate_path())
		return true
	else:
		return false
