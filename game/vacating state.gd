extends State

@export var taxiway_detection : Area3D
@export var controller : AircraftController
@export var taxi_in_state : State
var landing_runway : int = 21
@onready var pathfind : pathfinder

func Enter() -> void:
	controller.target_speed = 50

var mover : TaxiMovement

func Exit() -> void:
	if mover != null:
		mover.free()

func Update(_delta) -> void:
	if not mover:
		for area : CollisionObject3D in taxiway_detection.get_overlapping_areas().filter(func(a): return a.owner is taxiway):
			var tw : taxiway = area.owner
			#print(tw.name)
			if not tw.vacate.has(landing_runway):
				continue
			
			# vacate of tw.
			Game.chat.send_message("Vacating via " + tw.name)
			mover = TaxiMovement.new(FixVacateCurve(tw.curve, controller.get_steering_wheel().global_position), controller, 50)
			mover.stopping_distance_per_kts += 2
			mover.done.connect(func(): state_transition.emit(self, "static"))
			add_child(mover)
	
	else:
		if not Game.runway in taxiway_detection.get_overlapping_areas(): # Aircraft is clear of runway
			mover.queue_free()
			state_transition.emit(self, "static")

## Takes in a curve and makes sure point index 0 is the side closest to the given position. Also places a duplicate of the first point right on the centerline (first).
func FixVacateCurve(originCurve : Curve3D, pos : Vector3) -> Curve3D:
	var points : Array[Vector3] = []
	for i : int in range(originCurve.point_count):
		points.append(originCurve.get_point_position(i))
	
	var curve := Curve3D.new()
	
	if points.back().distance_to(pos) < points.front().distance_to(pos):
		points.reverse()
	
	curve.add_point(Vector3(points.front().x, points.front().y, 0)) 
	
	for p : Vector3 in points:
		curve.add_point(p)
	return curve
