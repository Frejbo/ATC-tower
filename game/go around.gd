extends Button

@export var behaviour_FSM : FiniteStateMachine

func _pressed() -> void:
	behaviour_FSM.landing_clearance = false
	behaviour_FSM.change_state(behaviour_FSM.current_state, "go around")
