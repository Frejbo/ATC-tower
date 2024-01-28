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
	if travel_curve.point_count > 0:
		taxi_aircraft(delta)

func taxi_aircraft(delta : float) -> void:
	var closest_distance : float = 1
	while travel_curve.get_point_position(0).distance_to(aircraft_body.nosewheel.global_position) < closest_distance:
		travel_curve.remove_point(0)
		print("Removing point")
	
	var direction : float = aircraft_body.nosewheel.global_position.angle_to(travel_curve.get_point_position(0))
	print(angle_difference(direction, aircraft_body.global_rotation.y))
	aircraft_body.nosewheel.steering = angle_difference(direction, aircraft_body.nosewheel.rotation.y)
	
	travel_curve.clear_points()
