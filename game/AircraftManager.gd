extends Node3D

@export var aircraftScene : PackedScene

signal list_updated
var aircrafts : Array[aircraft]:
	set(val):
		aircrafts = val
		print("emitting")
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
