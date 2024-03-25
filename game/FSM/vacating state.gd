extends State

@export var taxiway_detection : Area3D
@export var body_detection : Area3D
@export var controller : AircraftController
@export var taxi_in_state : State
var landing_runway : int = 21
@onready var pathfind : pathfinder

@export var comm_manager : communication_manager

func Enter() -> void:
	controller.target_speed = 50

var mover : TaxiMovement

var vacating_taxiway : taxiway

func Exit() -> void:
	Game.chat.send_message("Vacated via " + vacating_taxiway.name + ", requesting taxi to stand.", owner.callsign)
	comm_manager.set_visibility(comm_manager.TAXI_TO_STAND, true)
	if mover != null:
		mover.free()

func Update(_delta) -> void:
	if not mover:
		for area : CollisionObject3D in taxiway_detection.get_overlapping_areas().filter(func(a): return a.owner is taxiway):
			vacating_taxiway = area.owner
			#print(tw.name)
			if not vacating_taxiway.vacate.has(landing_runway):
				continue
			
			
			# vacate of tw.
			mover = TaxiMovement.new(FixVacateCurve(vacating_taxiway.curve, controller.get_steering_wheel().global_position), controller, 50)
			mover.stopping_distance_per_kts += 2
			mover.done.connect(func(): state_transition.emit(self, "static"))
			add_child(mover)
	
	else:
		if not Game.runway in body_detection.get_overlapping_areas(): # Aircraft is clear of runway
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
