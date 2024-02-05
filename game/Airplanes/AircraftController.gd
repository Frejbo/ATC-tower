extends FlightPhysics

class_name AircraftController

func get_steering_wheel() -> VehicleWheel3D:
	for child : Node in get_children():
		if child is VehicleWheel3D and child.use_as_steering:
			return child
	return null

func _process(_delta: float) -> void:
	thrust_lever = $CanvasLayer/thrust.value
