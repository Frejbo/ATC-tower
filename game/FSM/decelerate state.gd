extends State

@export var controller : AircraftController

func Enter() -> void:
	controller.target_speed = controller.max_straight_taxi_speed_kts

func Update(_delta) -> void:
	if controller.get_speed_kts() < 40:
		state_transition.emit(self, "taxi")
