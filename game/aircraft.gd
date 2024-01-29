extends Node3D

class_name aircraft

@export var callsign : String:
	set(val):
		callsign = val.to_upper()
		name = callsign
		%callsign.text = callsign

@export var communicator : aircraft_communicator
@export var aircraft_body : VehicleBody3D

func _enter_tree() -> void:
	communicator.taxi_instruction_recieved.connect(func(path : Curve3D): travel_curve = path)
	aircraft_body.thrust_lever_percentage = 1

var travel_curve : Curve3D = Curve3D.new():
	set(curve):
		travel_curve.clear_points()
		for baked_point in curve.get_baked_points():
			travel_curve.add_point(baked_point)

func show_communication_window() -> void:
	communicator.show()
func hide_communication_window() -> void:
	communicator.hide()


func _physics_process(delta: float) -> void:
	#print("point", travel_curve.point_count)
	if travel_curve.point_count > 0:
		taxi_aircraft(delta)

func taxi_aircraft(_delta : float) -> void:
	print()
	var closest_distance : float = 5
	while aircraft_body.nosewheel.global_position.distance_to(travel_curve.get_point_position(0)) < closest_distance:
		print("Removing point, total: ", travel_curve.point_count)
		travel_curve.remove_point(0)
	
	
	var direction = (travel_curve.get_point_position(0) - aircraft_body.nosewheel.global_position).normalized()
	var target_rotation = atan2(direction.x, direction.z) - aircraft_body.rotation.y
	target_rotation = clamp(target_rotation, -deg_to_rad(aircraft_body.max_nosewheel_steering_degrees), deg_to_rad(aircraft_body.max_nosewheel_steering_degrees))
	aircraft_body.steering = target_rotation
	print(target_rotation)
	$"Cylinder A320 Neo/arrow".rotation_degrees.y = rad_to_deg(target_rotation) - 90
