extends State

@export var comm_manager : communication_manager

func Enter() -> void:
	comm_manager.set_visibility(comm_manager.GO_AROUND, false)
	comm_manager.set_visibility(comm_manager.CONTINUE_APPROACH, false)
	comm_manager.set_visibility(comm_manager.TAKEOFF_CLEARANCE, false)
	
	
	Game.chat.send_message("Going around " + owner.callsign, "", true, Color.RED)
	await get_tree().physics_frame
	state_transition.emit(self, "takeoff")
