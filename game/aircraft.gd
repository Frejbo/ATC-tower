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
	aircraft_body.thrust_lever_percentage = 1

func show_communication_window() -> void:
	communicator.show()
func hide_communication_window() -> void:
	communicator.hide()
