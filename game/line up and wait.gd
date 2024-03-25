extends Button

@export var behaviour_FSM : FiniteStateMachine
@export var hold_short_state : State
@export var comm_manager : communication_manager

func _pressed() -> void:
	behaviour_FSM.change_state(hold_short_state, "line up")
	comm_manager.set_visibility(comm_manager.LINE_UP, false)
