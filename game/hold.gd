extends Button


@export var hold_label : String = "Hold position"
@export var resume_label : String = "Resume taxiing"
@export var behaviour_FSM : FiniteStateMachine

func _pressed() -> void:
	behaviour_FSM.hold = !behaviour_FSM.hold
	check_text()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		check_text()

func check_text() -> void:
	if behaviour_FSM.hold:
		text = resume_label
	else:
		text = hold_label
