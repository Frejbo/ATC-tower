extends Node3D

class_name Aircraft

@export var callsign : String = "NORDO":
	set(val):
		callsign = val.to_upper()
		name = callsign
		%callsign.text = callsign

@export var comm_manager : communication_manager
@export var controller : AircraftController
@export var behaviour_FSM : FiniteStateMachine
@export var body_detection : Area3D

func show_communication_window() -> void:
	comm_manager.show()
func hide_communication_window() -> void:
	comm_manager.hide()


@export var taxi_to_stand_stand_input : LineEdit
func _ready() -> void:
	
	# Check if on ground and if so, switch state to static. If at gate, switch to loading
	await get_tree().physics_frame
	if controller.global_position.y < 1:
		print(callsign + " is initially on ground...")
		print("Switching " + callsign + " behaviour to static.")
		behaviour_FSM.change_state(behaviour_FSM.current_state, "static")
		comm_manager.hide_all()
		await get_tree().physics_frame
		if not body_detection.get_overlapping_areas().filter(func(a): return a is Gate).is_empty(): # if is at any gate
			print(callsign + " seems to be at a gate, switching behaviour to loading.")
			behaviour_FSM.change_state(behaviour_FSM.current_state, "loading")
		else:
			comm_manager.set_visibility(comm_manager.TAXI_TO_RUNWAY, true)
			comm_manager.set_visibility(comm_manager.TAXI_TO_STAND, true)
		return
	
	# Set a random available stand as temporary destination
	var available_stands : Array[Gate] = []
	for stand in Game.stands.values():
		if stand.is_occupied(): continue
		available_stands.append(stand)
	if not available_stands.is_empty():
		taxi_to_stand_stand_input.text = available_stands.pick_random().name
