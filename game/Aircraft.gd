extends Node3D

class_name Aircraft

@export var callsign : String = "NORDO":
	set(val):
		callsign = val.to_upper()
		name = callsign
		%callsign.text = callsign

@export var comm_manager : communication_manager

func show_communication_window() -> void:
	comm_manager.show()
func hide_communication_window() -> void:
	comm_manager.hide()

