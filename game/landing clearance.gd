extends Button

@export var behaviour_FSM : FiniteStateMachine
@export var comm_manager : communication_manager

func _pressed() -> void:
	behaviour_FSM.landing_clearance = true
	comm_manager.set_visibility(comm_manager.CONTINUE_APPROACH, false)
	comm_manager.set_visibility(comm_manager.LANDING_CLEARANCE, false)
	
	Game.chat.send_message("Cleared to land runway 21.", owner.callsign)
