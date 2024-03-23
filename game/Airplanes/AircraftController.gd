extends FlightPhysics

class_name AircraftController


## Returns the wheel used for steering. In most cases the nosewheel.
func get_steering_wheel() -> VehicleWheel3D:
	for child : Node in get_children():
		if child is VehicleWheel3D and child.use_as_steering:
			return child
	return null

## Returns true if ANY of the wheels is colliding.
func is_on_ground() -> bool:
	for child : Node in get_children():
		if child is VehicleWheel3D and child.is_in_contact():
			return true
	return false

## Returns the speed in knots. Calculated based on velocity length, Vertical speed is therefore also included.
func get_speed_kts() -> float:
	return ms_to_kts(linear_velocity.length())


## Steers the nosewheel smoothly towards the target.
func steer_nosewheel(target : Vector3, delta : float):
	var fwd : Vector3 = linear_velocity.normalized()
	var target_vector : Vector3 = (target - get_steering_wheel().global_position)
	var steer_degrees : float = lerp(steering, fwd.cross(target_vector.normalized()).y, 2 * delta)
	steering = steer_degrees
