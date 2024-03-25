extends State

@export var controller : AircraftController
## When stopping, how many meters should be estimated per kts deceleration.[br]This equals the distance the plane will start to slow down to stop * the speed in kts.
@export var stopping_distance_per_kts : float = 3
@export var comm_manager : communication_manager
@export var body_detection : Area3D

var taxi_path : Curve3D
var mover : TaxiMovement
#var target_transform : Transform3D

func Enter() -> void:
	body_detection.area_entered.connect(area_entered)
	
	if taxi_path == null:
		printerr("Unable to taxi, the taxi state didn't recieve any taxipath.")
		state_transition.emit(self, "static")
		return
	mover = TaxiMovement.new(taxi_path, controller)
	add_child(mover)
	comm_manager.set_visibility(comm_manager.HOLD, true)

func area_entered(area) -> void:
	if area != Game.runway: return
	controller.target_speed = 0
	state_transition.emit(self, "hold short")

func Exit() -> void:
	comm_manager.set_visibility(comm_manager.HOLD, false)
	mover.queue_free()

#func done() -> void:
	#controller.global_transform = target_transform
