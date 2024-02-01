extends Resource

class_name FlightPhysics

## The current weight of the aircraft.
@export var mass : float = 50000
## Max amount of Newtons one engine can produce * the number of engines.
@export var max_thrust_N : int = 200000
## Abstract value to determine how fast the engines should react to thrust lever changes.[br]This won't translate to any real values.
@export var engine_spool_up_speed : int = 50
## The position of thrust the lever. 0 = 0% thrust, 1 = 100% thrust.[br]The actual thrust output is determined by a number of factors and can be accessed via get_forces().
@export_range(0, 1) var thrust_lever := 0.0
@export_category("Lift")
@export var Coefficient_of_lift : float = 1.75
## The total area of the wing given in square meters.
@export var wing_area : int = 100
@export_category("Taxi speeds")
## The speed in knots which the aircraft will aim to be at in turns.
@export var turn_speed_kts : int = 8
## The speed in knots which the aircraft will aim to be at on straight taxiways.
@export var max_straight_taxi_speed_kts : int = 28

var current_thrust_force := 0.0

func kts_to_ms(kts : float) -> float:
	return kts * 0.514444444
func ms_to_kts(meter_per_second : float) -> float:
	return meter_per_second * 1.94384449


func _physics_process(delta: float) -> void:
	print(thrust_lever)
	current_thrust_force = lerp(current_thrust_force, max_thrust_N * thrust_lever, engine_spool_up_speed * delta)

var velocity := Vector3.ZERO

func get_forces(linear_velocity : Vector3, rotation : Vector3) -> Vector3:
	velocity.z += current_thrust_force / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	velocity.y = get_lift(linear_velocity)
	return velocity.rotated(Vector3(0, 1, 0), rotation.y)


func get_lift(linear_velocity : Vector3) -> float:
	var air_density := 0.0752
	var velocity_squared = abs(linear_velocity.z * linear_velocity.z)
	#print(get_velocity())
	var lift : float = Coefficient_of_lift * air_density * (velocity_squared / 2.0) * wing_area
	var gravity_force : float = mass * ProjectSettings.get_setting("physics/3d/default_gravity")
	#print("lift: ", lift, " gravity force: ", gravity_force, " sum: ", lift - gravity_force)
	return lift - gravity_force

