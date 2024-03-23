extends Node3D

class_name Aircraft

@export var callsign : String = "NORDO":
	set(val):
		callsign = val.to_upper()
		name = callsign
		%callsign.text = callsign

@export var communicator : aircraft_communicator

func show_communication_window() -> void:
	communicator.show()
func hide_communication_window() -> void:
	communicator.hide()

