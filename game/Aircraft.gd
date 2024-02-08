extends Node3D

class_name Aircraft

@export var callsign : String:
	set(val):
		callsign = val.to_upper()
		name = callsign
		%callsign.text = callsign

@export var communicator : aircraft_communicator

func show_communication_window() -> void:
	communicator.show()
func hide_communication_window() -> void:
	communicator.hide()

#func _enter_tree() -> void:
	#if global_position.y > 10:
		#add_child(approach_component.new())
	#else:
		#add_child(taxi_component.new())
