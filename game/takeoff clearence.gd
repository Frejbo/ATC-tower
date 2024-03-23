extends Button

@export var behaviour_FSM : FiniteStateMachine

func _pressed() -> void:
	behaviour_FSM.change_state(behaviour_FSM.current_state, "takeoff")
