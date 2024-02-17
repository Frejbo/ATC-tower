extends Node3D

@export var aircraftScene : PackedScene

signal list_updated
var aircrafts : Dictionary:
	set(val):
		aircrafts = val
		list_updated.emit(aircrafts)

func _enter_tree() -> void:
	Game.AircraftManager = self
	child_entered_tree.connect(func(child): 
		aircrafts[child.callsign] = child
		aircrafts = aircrafts # just to trigger setget
		)
	child_exiting_tree.connect(func(child):
		aircrafts.erase(child.callsign)
		aircrafts = aircrafts # just to trigger setget
		)

func _ready() -> void:
	for child : Node in get_children():
		if child is Aircraft:
			aircrafts[child.callsign] = child
			aircrafts = aircrafts

func spawn(callsign : String, spawn_position : Vector3 = Vector3.ZERO) -> void:
	var plane = aircraftScene.instantiate()
	plane.position = spawn_position
	plane.callsign = callsign
	add_child(plane)
	if spawn_position == Vector3.ZERO:
		plane.global_position = Game.active_approach.get_position_at_distance(Game.active_approach.nm_to_m(.2))
		plane.global_rotation.y = Game.active_approach.global_rotation.y + deg_to_rad(-90)

func switch_communication_window_visibility(callsign : String) -> void:
	print(aircrafts)
	aircrafts[callsign].communicator.visible = !aircrafts[callsign].communicator.visible
