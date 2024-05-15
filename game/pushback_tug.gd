extends VehicleBody3D

class_name PushbackTug

signal connected_tug
signal fully_disconnected

## The distance from the aircraft which the tug spawns at and fades in.
@export var spawn_distance : float = 20
## The distance from the aircraft which the tug will drive and fade out at before it's fully disconnected
@export var disconnect_distance : float = 50

func _ready() -> void:
	connect_tug(Vector3(0, 0, 0), 90)

## Wheel direction is given in degrees
func connect_tug(wheel_position : Vector3, wheel_direction : float) -> void:
	# Set position
	rotation_degrees.y = wheel_direction - 180
	global_position = wheel_position + Vector3(0, 0, -spawn_distance).rotated(Vector3(0, 1, 0), deg_to_rad(wheel_direction))
	
	# Make all parts of the truck transparent
	# Fade in truck using tween
	var tween = get_tree().create_tween()
	for mesh : MeshInstance3D in get_meshes():
		mesh.transparency = 1
		tween.tween_property(mesh, "transparency", 0, 2).from(1)
		tween.set_parallel()
	tween.play()
	engine_force = mass / 5
	
	connected_tug.emit()

func disconnect_tug() -> void:
	fully_disconnected.emit()

func get_meshes(child_node : Node = self) -> Array[MeshInstance3D]:
	var meshes : Array[MeshInstance3D] = []
	for node : Node in child_node.get_children():
		if node.get_child_count() > 0:
			for n in get_meshes(node):
				meshes.append(n)
		else:
			if node is MeshInstance3D:
				meshes.append(node)
	return meshes
