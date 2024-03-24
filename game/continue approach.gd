extends Button

@export var comm_manager : communication_manager

func _pressed() -> void:
	comm_manager.set_visibility(comm_manager.CONTINUE_APPROACH, false)
	Game.chat.send_message("Continuing approach.", owner.callsign)
