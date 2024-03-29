extends Button

#signal taxi_to_stand(stand : Marker3D, route : Array[String])

@export var controller : AircraftController
@export var airplane : Aircraft
@export var behaviour_FSM : FiniteStateMachine
@onready var taxi_pathfind : pathfinder


func _pressed() -> void:
	if not Game.stands.has($HBoxContainer/stand.text): return
	taxi_to_stand(Game.stands.get($HBoxContainer/stand.text), $HBoxContainer/route.get_route())


func taxi_to_stand(stand : Gate, route : Array[String]) -> void:
	# Send chat message
	var chatMessage := airplane.callsign + " taxi to stand " + stand.name + " via "
	for s : String in route:
		chatMessage += s + ", "
	chatMessage = chatMessage.left(-2)
	chatMessage += "."
	
	route.append(stand.taxiway_in.name)
	
	Game.chat.send_tower_message(chatMessage)
	print("To stand pos: ", stand.global_position, "  via: ", route)
	taxi_to(stand.global_position, route)


func taxi_to(pos : Vector3, route : Array[String]) -> void:
	taxi_pathfind = pathfinder.new(controller.get_steering_wheel().global_position, pos, route)
	print("target: ", pos)
	if await taxi_pathfind.path_is_valid():
		set_taxi_state(await taxi_pathfind.calculate_path())


func set_taxi_state(route : Curve3D) -> void:
	if not behaviour_FSM.states.has("taxi in"):
		printerr("taxi in state was not found in AircraftBehaviourManager.")
		return
	behaviour_FSM.states.get("taxi in").taxi_path = route
	
	if behaviour_FSM.current_state.name == "static":
		behaviour_FSM.change_state(behaviour_FSM.current_state, "taxi in")
