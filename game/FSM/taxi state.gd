extends State

@export var controller : AircraftController
## When stopping, how many meters should be estimated per kts deceleration.[br]This equals the distance the plane will start to slow down to stop * the speed in kts.
@export var stopping_distance_per_kts : float = 3

var taxi_path := Curve3D.new():
	set(curve):
		taxi_path.clear_points()
		for point in curve.tessellate_even_length():
			taxi_path.add_point(point)
			
			#var mesh = CSGBox3D.new()
			#mesh.size = Vector3(10, 10, 10)
			#add_child(mesh)
			#mesh.global_position = point


func Update(delta : float) -> void:
	if taxi_path == null or taxi_path.point_count == 0:
		state_transition.emit(self, "static")
		return
	move(delta)


func move(delta : float) -> void:
	var closest_distance : float = clamp(taxi_path.point_count/2.0, .5, 10)
	while controller.get_steering_wheel().global_position.distance_to(taxi_path.get_point_position(0)) < closest_distance:
		taxi_path.remove_point(0)
		if taxi_path.point_count == 0:
			controller.steering = 0
			return
	
	# Calculate target speed
	controller.target_speed = get_safe_speed(get_upcoming_curvature())
	
	steer_nosewheel(taxi_path.get_point_position(0), delta)
	controller.get_node("Node/current navigation aid").position = taxi_path.get_point_position(0)

## Steers the nosewheel smoothly towards the target.
func steer_nosewheel(target : Vector3, delta : float):
	var fwd : Vector3 = controller.linear_velocity.normalized()
	var target_vector : Vector3 = (target - controller.get_steering_wheel().global_position)
	var steer_degrees : float = lerp(controller.steering, fwd.cross(target_vector.normalized()).y, 2 * delta)
	controller.steering = steer_degrees

## Calculates the safe taxi speed depending on the upcoming taxiway curvature given in radians. The returned speed is dependent on 'max_straight_taxi_speed_kts' and 'turn_speed_kts'. 
func get_safe_speed(curvature : float) -> float:
	
	curvature = rad_to_deg(abs(curvature))
	# curve range 3 - 30
	var min_react_deg : float = 3
	var max_react_deg : float = 30
	var safe_speed : float
	if curvature < min_react_deg:
		safe_speed = controller.max_straight_taxi_speed_kts
	elif curvature > max_react_deg:
		safe_speed = controller.turn_speed_kts
	else:
		# curvature degree is in a range where speed should gradually be adjusted.
		var varying_speed_range : float = controller.max_straight_taxi_speed_kts - controller.turn_speed_kts
		var curvature_percent : float = 1.0 / (curvature - min_react_deg)
		safe_speed = controller.turn_speed_kts + (varying_speed_range * curvature_percent)
	
	var distance_left : float = 0
	if taxi_path.point_count > 0:
		distance_left += controller.get_steering_wheel().global_position.distance_to(taxi_path.get_point_position(0))
	if taxi_path.point_count >= 2:
		distance_left += taxi_path.get_baked_length()
	var stopping_multiplier : float = clamp(distance_left / (stopping_distance_per_kts * safe_speed), 0, 1)
	
	print(safe_speed, "  multiplier: ", stopping_multiplier)
	return clamp(safe_speed * stopping_multiplier, 2, controller.max_straight_taxi_speed_kts)

## Get curvature of the given Vector3D points in radians. Can be used to get taxiway curvature for example. Returns radians.
func get_upcoming_curvature(sample_length : int = 50) -> float:
	
	var points : Array[Vector3] = [controller.get_steering_wheel().global_position]
	var calculated_length : float = 0
	var idx : int = 0
	while calculated_length < sample_length and idx < taxi_path.point_count: # -1?
		calculated_length += points.back().distance_to(taxi_path.get_point_position(idx))
		points.append(taxi_path.get_point_position(idx))
		idx += 1
	
	if points.size() <= 2: return 0 # 2 points can only be straight, less is not a line
	
	# Calculate the direction vector between the first and last point
	var direction_vector : Vector3 = points[1] - points.front()
	var final_vector : Vector3 = points.back() - points.front()
	
	# Convert vector directions into radians
	var direction : float = points.front().signed_angle_to(direction_vector, Vector3(0, 1, 0))
	var final_direction : float = points.front().signed_angle_to(final_vector, Vector3(0, 1, 0))
	
	return final_direction - direction
