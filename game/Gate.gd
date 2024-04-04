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
@export var push_procedure : pushback_points:
	set(val):
		push_procedure = val
		if val != null:
			val.updated_points.connect(preview_pushback_points)

@export var pushpoint_preview : PackedScene
func preview_pushback_points(points : Array) -> void:
	for child in get_children():
		if child.is_in_group("pushpoint preview"):
			child.free()
	
	for p in points:
		var scene = pushpoint_preview.instantiate()
		scene.position.x = p.position.x
		scene.position.z = p.position.y
		scene.rotation_degrees.y = p.rotation
		scene.owner = self
		add_child(scene)

func _enter_tree() -> void:
	Game.stands[stand_name] = self

func is_occupied() -> bool:
	return not get_overlapping_bodies().filter(
		func(body):
			return body is AircraftController
			).is_empty()
