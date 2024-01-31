extends Node

@export var aircraft_body : aircraft

func taxi(route : Curve3D):
	taxi_path = route

var taxi_path : Curve3D:
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

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta : float) -> void:
	var closest_distance : float = 10
	while aircraft_body.nosewheel.global_position.distance_to(taxi_path.get_point_position(0)) < closest_distance:
		taxi_path.remove_point(0)
		if taxi_path.point_count == 0:
			set_physics_process(false)
			aircraft_body.steering = 0
			return
	
	steer_nosewheel(taxi_path.get_point_position(0), delta)
	aircraft_body.get_node("Node/current navigation aid").position = taxi_path.get_point_position(0)

func steer_nosewheel(target : Vector3, delta : float):
	var fwd : Vector3 = aircraft_body.linear_velocity.normalized()
	var target_vector : Vector3 = (target - aircraft_body.nosewheel.global_position)
	var steer_degrees : float = lerp(aircraft_body.steering, fwd.cross(target_vector.normalized()).y, 50 * delta) 
	aircraft_body.steering = steer_degrees
