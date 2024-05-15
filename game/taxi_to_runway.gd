extends Button

#signal taxi_to_stand(stand : Marker3D, route : Array[String])

@export var controller : AircraftController
@export var airplane : Aircraft
@export var behaviour_FSM : FiniteStateMachine
@onready var taxi_pathfind : pathfinder

func _pressed() -> void:
	var route : Array[String] = []
	for s : String in $HBoxContainer/route.text.split(","):
		route.append(s)
	var takeoff_point = route.back()
	if not Game.runway.takeoff_points.has(takeoff_point):
		printerr("Didn't found takeoff point " + str(takeoff_point))
		return
	
	takeoff_point = Game.runway.takeoff_points.get(takeoff_point)
	behaviour_FSM.takeoff_point = takeoff_point
	
	# Send chat message
	Game.chat.send_tower_message(owner.callsign + " taxi to runway 21 via " + $HBoxContainer/route.text + ".")
	Game.chat.send_message("Taxi to runway 21 via " + $HBoxContainer/route.text + owner.callsign)
	
	taxi_to(takeoff_point.global_transform.origin, route)



#signal taxi_instruction_recieved(route : Curve3D, target_transform : Transform3D)
func taxi_to(pos : Vector3, route : Array[String]) -> void:
	taxi_pathfind = pathfinder.new(controller.get_steering_wheel().global_position, pos, route)
	print("target: ", pos)
	if await taxi_pathfind.path_is_valid():
		set_behaviour_state(await taxi_pathfind.calculate_path())
	else:
		OS.alert("Unable to reach target via " + str(route))


func set_behaviour_state(route : Curve3D) -> void:
	if not behaviour_FSM.states.has("taxi out"):
		printerr("taxi out state was not found in AircraftBehaviourManager.")
		return
	behaviour_FSM.states.get("taxi out").taxi_path = route
	
	if behaviour_FSM.current_state.name == "static":
		behaviour_FSM.change_state(behaviour_FSM.current_state, "taxi out")
