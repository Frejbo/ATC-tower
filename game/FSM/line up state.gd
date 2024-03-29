extends State

@export var behaviour_FSM : FiniteStateMachine
@export var controller : AircraftController

func Enter() -> void:
	# Send message
	Game.chat.send_message("Line up and wait runway 21. " + owner.callsign)
	
	# Line up
	call_deferred("teleport")
	
	# Takeoff if takeoff clearance has been issued.
	if behaviour_FSM.takeoff_clearance:
		state_transition.emit(self, "takeoff")

func teleport():
	controller.steering = 0
	controller.global_transform = behaviour_FSM.takeoff_point.global_transform
	#controller.global_position = behaviour_FSM.takeoff_point.global_position
	#controller.global_rotation = behaviour_FSM.takeoff_point.global_rotation

func Update(_delta) -> void:
	if behaviour_FSM.takeoff_clearance:
		state_transition.emit(self, "takeoff")
