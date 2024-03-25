extends State

@export var behaviour_FSM : FiniteStateMachine
@export var controller : AircraftController

func Enter() -> void:
	# Send message
	Game.chat.send_message("Line up and wait runway 21.", owner.callsign)
	
	# Line up
	controller.global_transform = behaviour_FSM.takeoff_point.global_transform
	
	# Takeoff?
	if behaviour_FSM.takeoff_clearance:
		state_transition.emit(self, "takeoff")

func Update(_delta) -> void:
	if behaviour_FSM.takeoff_clearance:
		state_transition.emit(self, "takeoff")
