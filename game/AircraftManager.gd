extends Node3D

@export var aircraftScene : PackedScene

signal list_updated
var aircrafts : Array[Aircraft]:
	set(val):
		aircrafts = val
		list_updated.emit(aircrafts)

func _enter_tree() -> void:
	Game.AircraftManager = self
	child_entered_tree.connect(func(child): 
		aircrafts.append(child)
		aircrafts = aircrafts)
	child_exiting_tree.connect(func(child): 
		aircrafts.erase(child)
		aircrafts = aircrafts)

func spawn(callsign : String, spawn_position : Vector3 = Vector3.ZERO) -> void:
	var plane = aircraftScene.instantiate()
	plane.position = spawn_position
	plane.callsign = callsign
	add_child(plane)
	if spawn_position == Vector3.ZERO:
		plane.global_position = Game.active_approach.get_position_at_distance(Game.active_approach.nm_to_m(1))
		plane.global_rotation.y = Game.active_approach.global_rotation.y + deg_to_rad(-90)
