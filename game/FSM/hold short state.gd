extends State

@export var comm_manager : communication_manager
@export var behaviour_FSM : FiniteStateMachine

func Enter() -> void:
	# Send message
	Game.chat.send_message("Holding short of runway 21 at " + behaviour_FSM.takeoff_point.name, owner.callsign)
	
	comm_manager.hide_all()
	comm_manager.set_visibility(comm_manager.TAKEOFF_CLEARANCE, true)
	comm_manager.set_visibility(comm_manager.LINE_UP_AND_WAIT, true)
	
