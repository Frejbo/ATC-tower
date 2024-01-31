extends VehicleBody3D


@export var nosewheel : VehicleWheel3D
@export var max_thrust_N : int
@export var engine_spool_up_speed : int
@export_category("Lift")
@export var Coefficient_of_lift : float
@export var wing_area : int
@export_category("Taxi speeds")
@export var max_turn_speed_kts : int = 10
@export var max_straight_taxi_speed_kts : int = 28

var thrust_lever_percentage := 0.0
var current_thrust_force := 0.0
var target_speed := 0.0

func kts_to_ms(kts : float) -> float:
	return kts * 0.514444444
func ms_to_kts(meter_per_second : float) -> float:
	return meter_per_second * 1.94384449


func _physics_process(delta: float) -> void:
	thrust_lever_percentage = $CanvasLayer/thrust.value
	
	current_thrust_force = lerp(current_thrust_force, max_thrust_N * thrust_lever_percentage, engine_spool_up_speed * delta)


var velocity := Vector3.ZERO
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	velocity.z += current_thrust_force / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	velocity.y = get_lift()
	#print(velocity)
	state.set_constant_force(velocity.rotated(Vector3(0, 1, 0), rotation.y))

func get_velocity() -> float:
	return linear_velocity.z

func get_lift() -> float:
	var air_density := 0.0752
	var velocity_squared = abs(get_velocity() * get_velocity())
	#print(get_velocity())
	var lift : float = Coefficient_of_lift * air_density * (velocity_squared / 2.0) * wing_area
	var gravity_force : float = mass * ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_scale
	#print("lift: ", lift, " gravity force: ", gravity_force, " sum: ", lift - gravity_force)
	return lift - gravity_force

func steer_wheel(delta : float) -> void:
	var axis := Input.get_axis("ui_right", "ui_left")
	steering = lerp(steering, deg_to_rad(80) * axis, 5 * delta)
	steering = lerp(steering, deg_to_rad(20) * axis, 5 * delta)
