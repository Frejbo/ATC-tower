extends Button

@export var behaviour_FSM : FiniteStateMachine
@export var comm_manager : communication_manager

func _pressed() -> void:
	behaviour_FSM.takeoff_clearance = true
	behaviour_FSM.change_state(behaviour_FSM.current_state, "line up")
	comm_manager.hide_all()
	Game.chat.send_tower_message(owner.callsign + " cleared for takeoff runway 21.")
	Game.chat.send_message("Runway 21, cleared for takeoff, " + owner.callsign)
