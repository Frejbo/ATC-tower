extends State

@export var controller : AircraftController

var default_linear_damp : float
func Enter() -> void:
	controller.target_speed = controller.max_straight_taxi_speed_kts
	default_linear_damp = controller.linear_damp
	controller.linear_damp = .01

func Update(_delta) -> void:
	if controller.get_speed_kts() < 60:
		state_transition.emit(self, "vacating")

func Exit() -> void:
	controller.linear_damp = default_linear_damp
