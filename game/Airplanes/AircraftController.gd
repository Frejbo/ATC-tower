extends VehicleBody3D

class_name AircraftController
var target_speed := 0.0

@export var physics := FlightPhysics.new()

func get_steering_wheel() -> VehicleWheel3D:
	for child : Node in get_children():
		if child is VehicleWheel3D and child.use_as_steering:
			return child
	return null

func _process(_delta: float) -> void:
	physics.thrust_lever = $CanvasLayer/thrust.value

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.set_constant_force(physics.get_forces(linear_velocity, rotation))
	print(physics.get_forces(linear_velocity, rotation))
