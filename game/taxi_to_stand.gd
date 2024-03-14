extends Button

#signal taxi_to_stand(stand : Marker3D, route : Array[String])

@export var body : AircraftController
@export var airplane : Aircraft
@onready var taxi_pathfind : pathfinder

func _pressed() -> void:
	if not Game.stands.has(%stand.text): return
	taxi_to_stand(Game.stands.get(%stand.text), %route.get_route())
	hide()



func taxi_to_stand(stand : Marker3D, route : Array[String]) -> bool:
	# Send chat message
	var chatMessage := airplane.callsign + " taxi to stand " + stand.name + " via "
	for s : String in route:
		chatMessage += s + ", "
	chatMessage = chatMessage.left(-2)
	chatMessage += "."
	
	route.append(stand.taxiway_in.name)
	
	Game.chat.send_tower_message(chatMessage)
	print("To stand pos: ", stand.global_position, "  via: ", route)
	return await taxi_to(stand.global_position, route)

signal taxi_instruction_recieved(route : Curve3D)
func taxi_to(pos : Vector3, route : Array[String]) -> bool:
	taxi_pathfind = pathfinder.new(body.get_steering_wheel().global_position, pos, route)
	print("target: ", pos)
	if await taxi_pathfind.path_is_valid():
		taxi_instruction_recieved.emit(await taxi_pathfind.calculate_path())
		return true
	else:
		return false
