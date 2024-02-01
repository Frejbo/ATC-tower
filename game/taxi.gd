extends Node

@export var body : AircraftController

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
	
	steer_nosewheel(taxi_path.get_point_position(0), delta)
	body.get_node("Node/current navigation aid").position = taxi_path.get_point_position(0)

func steer_nosewheel(target : Vector3, delta : float):
	var fwd : Vector3 = body.linear_velocity.normalized()
	var target_vector : Vector3 = (target - body.get_steering_wheel().global_position)
	var steer_degrees : float = lerp(body.steering, fwd.cross(target_vector.normalized()).y, 50 * delta) 
	body.steering = steer_degrees
