extends State

@export var controller : AircraftController

func Enter() -> void:
	controller.steering = 0
	controller.target_speed = 0
