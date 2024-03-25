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

func show_communication_window() -> void:
	comm_manager.show()
func hide_communication_window() -> void:
	comm_manager.hide()

func _ready() -> void:
	await get_tree().physics_frame
	if controller.global_position.y < 1:
		print(callsign + " is initially on ground, switching behaviour to static.")
		behaviour_FSM.change_state(behaviour_FSM.current_state, "static")
		comm_manager.hide_all()
		# if at gate...
		comm_manager.set_visibility(comm_manager.TAXI_TO_RUNWAY, true)
		comm_manager.set_visibility(comm_manager.TAXI_TO_STAND, true)
