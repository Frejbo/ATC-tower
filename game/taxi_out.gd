extends State

@export var controller : AircraftController
## When stopping, how many meters should be estimated per kts deceleration.[br]This equals the distance the plane will start to slow down to stop * the speed in kts.
@export var stopping_distance_per_kts : float = 3

var taxi_path : Curve3D

var target_transform : Transform3D

func Enter() -> void:
	if taxi_path == null:
		printerr("Unable to taxi, the taxi state didn't recieve any taxipath.")
		state_transition.emit(self, "static")
		return
	var mover := TaxiMovement.new(taxi_path, controller)
	mover.done.connect(done)
	add_child(mover)
	print(mover.taxi_path)


func done() -> void:
	controller.global_transform = target_transform
	state_transition.emit(self, "static")