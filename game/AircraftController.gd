extends VehicleBody3D


@export var nosewheel : VehicleWheel3D
@export var max_nosewheel_steering_degrees : int
@export var max_thrust_N : int
@export var engine_spool_up_speed : int
@export_category("Lift")
@export var Coefficient_of_lift : float
@export var wing_area : int

var thrust_lever_percentage : float
var current_thrust_force : float = 0

func _physics_process(delta: float) -> void:
	thrust_lever_percentage = $CanvasLayer/thrust.value
	
	current_thrust_force = lerp(current_thrust_force, max_thrust_N * thrust_lever_percentage, engine_spool_up_speed * delta)
	steer_wheel(delta)

var velocity := Vector3.ZERO
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	velocity.z += current_thrust_force / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	velocity.y = get_lift()
	print(velocity)
	state.set_constant_force(velocity.rotated(Vector3(0, 1, 0), rotation.y))

func get_velocity() -> float:
	return linear_velocity.z

func get_lift() -> float:
	var air_density := 0.0752
	var lift : float = Coefficient_of_lift * air_density * (get_velocity() * get_velocity() / 2) * wing_area
	var gravity_force : float = mass * ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_scale
	print("lift: ", lift, " gravity force: ", gravity_force, " sum: ", lift - gravity_force)
	return lift - gravity_force


func steer_wheel(delta : float) -> void:
	var axis := Input.get_axis("ui_right", "ui_left")
	steering = lerp(steering, deg_to_rad(max_nosewheel_steering_degrees) * axis, 5 * delta)
