extends State

@export var controller : AircraftController

func Enter() -> void:
	#controller.linear_velocity = Vector3.ZERO
	controller.steering = 0
	controller.target_speed = 0
	controller.get_steering_wheel().steering = 0
