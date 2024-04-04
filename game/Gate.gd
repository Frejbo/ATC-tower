@tool
extends Area3D

class_name Gate

@export var stand_name : String:
	set(text):
		if text == "":
			name = "Gate"
			stand_name = ""
			return
		name = text.to_upper()
		stand_name = text.to_upper()

@export var taxiway_in : taxiway = get_parent()
@export var push_procedure : pushback_points

func _enter_tree() -> void:
	Game.stands[stand_name] = self

func is_occupied() -> bool:
	return not get_overlapping_bodies().filter(
		func(body):
			return body is AircraftController
			).is_empty()
