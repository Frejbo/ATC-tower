extends State

@export var taxiway_detection : Area3D
@export var controller : AircraftController
@export var taxi_state : State
var landing_runway : int = 21
@onready var pathfind : pathfinder

func Enter() -> void:
	controller.target_speed = 50

var vacating_path := Curve3D.new():
	set(curve):
		for point in curve.tessellate_even_length():
			vacating_path.add_point(point)

func Update(delta) -> void:
	if vacating_path.point_count > 0:
		if Game.runway in taxiway_detection.get_overlapping_areas():
			taxi_state.move(delta, vacating_path)
			print(vacating_path)
		else:
			state_transition.emit(self, "static")
		return
	
	
	for area : CollisionObject3D in taxiway_detection.get_overlapping_areas():
		if area.owner is taxiway:
			var tw : taxiway = area.owner
			if not tw.vacate.has(landing_runway):
				continue
			
			# vacate of tw.
			vacating_path = tw.curve
			Game.chat.send_message("Vacating via " + tw.name)

func Exit() -> void:
	pass
