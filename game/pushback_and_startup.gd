extends Button

@export var behaviour_FSM : FiniteStateMachine
@export var static_state : State
@export var comm_manager : communication_manager

func _pressed() -> void:
	Game.chat.send_tower_message(owner.callsign + ", pushback and startup approved facing north.")
	Game.chat.send_message("Pushback and startup approved facing north, " + owner.callsign, owner.callsign)
	
	behaviour_FSM.change_state(static_state, "pushback")
	comm_manager.hide_all()
