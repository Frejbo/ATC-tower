extends Node3D

class_name aircraft

@export var callsign : String:
	set(val):
		callsign = val.to_upper()
		%callsign.text = callsign


func _enter_tree() -> void:
	Controller.aircrafts.append(self)

func _exit_tree() -> void:
	Controller.aircrafts.erase(self)

func _init(new_callsign : String) -> void:
	callsign = new_callsign
