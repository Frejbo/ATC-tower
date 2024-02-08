extends Node
class_name taxi_component

@export var body : AircraftController
@export var straight_taxi_speed_kts : float = 28
@export var turn_speed_kts : float = 8

func taxi(route : Curve3D):
	taxi_path = route

var taxi_path := Curve3D.new():
	set(curve):
		taxi_path.clear_points()
		for point in curve.tessellate_even_length():
			taxi_path.add_point(point)
			
			#var mesh = CSGBox3D.new()
			#mesh.size = Vector3(10, 10, 10)
			#add_child(mesh)
			#mesh.global_position = point
		if taxi_path.point_count > 0:
			set_physics_process(true)

func _enter_tree() -> void:
	set_physics_process(false)
func _physics_process(delta: float) -> void:
	if taxi_path != null and taxi_path.point_count > 0:
		move(delta)

func move(delta : float) -> void:
	var closest_distance : float = 10
	while body.get_steering_wheel().global_position.distance_to(taxi_path.get_point_position(0)) < closest_distance:
		taxi_path.remove_point(0)
		if taxi_path.point_count == 0:
			set_physics_process(false)
			body.steering = 0
			return
	
	# Calculate target speed
	body.target_speed = get_safe_speed(get_upcoming_curvature())
	
	steer_nosewheel(taxi_path.get_point_position(0), delta)
	body.get_node("Node/current navigation aid").position = taxi_path.get_point_position(0)

## Steers the nosewheel smoothly towards the target.
func steer_nosewheel(target : Vector3, delta : float):
	var fwd : Vector3 = body.linear_velocity.normalized()
	var target_vector : Vector3 = (target - body.get_steering_wheel().global_position)
	var steer_degrees : float = lerp(body.steering, fwd.cross(target_vector.normalized()).y, 2 * delta)
	body.steering = steer_degrees

## Calculates the safe taxi speed depending on the upcoming taxiway curvature given in radians. The returned speed is dependent on 'straight_taxi_speed_kts' and 'turn_speed_kts'. 
func get_safe_speed(curvature : float) -> float:
	curvature = rad_to_deg(abs(curvature))
	# curve range 5 - 30
	var min_react_deg : float = 3
	var max_react_deg : float = 30
	if curvature < min_react_deg:
		return straight_taxi_speed_kts
	if curvature > max_react_deg:
		return turn_speed_kts
	
	# curvature degree is in a range where speed should gradually be adjusted.
	var varying_speed_range : float = straight_taxi_speed_kts - turn_speed_kts
	var curvature_percent : float = 1.0 / (curvature - min_react_deg)
	
	return turn_speed_kts + (varying_speed_range * curvature_percent)

## Get curvature of the given Vector3D points in radians. Can be used to get taxiway curvature for example. Returns radians.
func get_upcoming_curvature(sample_length : int = 50) -> float:
	
	var points : Array[Vector3] = [body.get_steering_wheel().global_position]
	var calculated_length : float = 0
	var idx : int = 0
	while calculated_length < sample_length and idx < taxi_path.point_count: # -1?
		calculated_length += points.back().distance_to(taxi_path.get_point_position(idx))
		print(calculated_length)
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

