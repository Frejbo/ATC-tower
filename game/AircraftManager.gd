extends Node3D

@export var aircraftScene : PackedScene
@export var spawn_distance : float = 10

signal list_updated
var aircrafts : Dictionary:
	set(val):
		aircrafts = val
		list_updated.emit(aircrafts)

func _on_child_entered_tree(node: Node) -> void:
	if node is Aircraft:
		aircrafts[node.callsign] = node
		aircrafts = aircrafts # just to trigger setget

func _on_child_exiting_tree(node: Node) -> void:
	if not node is Aircraft: return
	if aircrafts.has(node.callsign):
		aircrafts.erase(node.callsign)
		aircrafts = aircrafts # just to trigger setget


func _enter_tree() -> void:
	Game.AircraftManager = self

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
		plane.global_position = Game.active_approach.get_position_at_distance(Game.active_approach.nm_to_m(spawn_distance))
		plane.global_rotation.y = Game.active_approach.global_rotation.y + deg_to_rad(180)

func switch_communication_window_visibility(callsign : String) -> void:
	print(aircrafts)
	aircrafts[callsign].comm_manager.visible = !aircrafts[callsign].comm_manager.visible

