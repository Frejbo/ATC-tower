extends VehicleBody3D

class_name FlightPhysics

## Max amount of Newtons one engine can produce * the number of engines.
@export var max_thrust_N : int = 200000
## Abstract value to determine how fast the engines should react to thrust lever changes.[br]This won't translate to any real values.
@export var engine_spool_up_speed : float = .5
## The position of thrust the lever. 0 = 0% thrust, 1 = 100% thrust.[br]The actual thrust output is determined by a number of factors and can be accessed via get_forces().[br][br]Note: You probably want to adjust this in-game.
@export_range(0, 1) var thrust_lever := 0.0:
	set(val):
		thrust_lever = val
		if val > 1:
			printerr("Thrust lever was set to above 1, meaning above 100%. Thrust might be higher than it should")
@export_category("Lift")
## The total area of the wing given in square meters.
@export var wing_area : int = 100
## The coefficient of lift (y axis) usually ranges from -1 - 2.[br]The Alpha/Angle of Attack degrees (x axis) ranging from -10° to 20° (0.0=-10°, 1.0=20°
@export var Cl_v_Alpha := Curve.new()
@export_category("Taxi speeds")
## The speed in knots which the aircraft will aim to be at in turns.
@export var turn_speed_kts : int = 10
## The speed in knots which the aircraft will aim to be at on straight taxiways.
@export var max_straight_taxi_speed_kts : int = 28
## The maximum amount of brake force the aircraft can apply
@export var max_brake_force : int = 1000
## The speed the aircraft should automatically aim for. Is updated every physics update. You probably want to set this during runtime.
@export var target_speed : float
## Main switch for disabling/enabling lift calculation.
@export var add_lift_force : bool = true

var current_thrust_force := 0.0

func kts_to_ms(kts : float) -> float:
	return kts * 0.514444444
func ms_to_kts(meter_per_second : float) -> float:
	return meter_per_second * 1.94384449

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		freeze = true

func _physics_process(delta: float) -> void:
	handle_speed(target_speed)
	current_thrust_force = lerp(current_thrust_force, max_thrust_N * thrust_lever, engine_spool_up_speed * delta)

#var total_time : float = Time.get_ticks_msec() * 0.001
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	%Speed.text = "Speed: " + str(round(ms_to_kts(Vector2(state.linear_velocity.x, state.linear_velocity.z).length()))) + " kts"
	#var delta : float = (Time.get_ticks_msec() * 0.001) - total_time
	#total_time = Time.get_ticks_msec() * 0.001
	#var gravity_force : float = ProjectSettings.get_setting("physics/3d/default_gravity")
	#state.linear_velocity.y -= gravity_force# * delta
	
	#var lift_accel = (get_lift_force() / mass)# * delta
	#state.linear_velocity.y += lift_accel
	#%TotalLift.text = "Total lift force: " + str(get_lift_force()) + " N"
	#%LiftAccel.text = "Lift acceleration: " + str(lift_accel) + " m/s"
	#%TotalLiftAccel.text = "Total lift acceleration: " + str(lift_accel - gravity_force) + " m/s"
	
	state.apply_force(Vector3(0, get_lift_force(), current_thrust_force).rotated(Vector3(0, 1, 0), global_rotation.y))


func get_acceleration(delta : float) -> float:
	# a = F / m
	return (current_thrust_force / mass) * delta

func get_lift_force() -> float:
	if not add_lift_force:
		return 0
	# Calculate angle of attack
	var AOA : float = rad_to_deg(-global_rotation.rotated(Vector3(0, 1, 0), global_rotation.y).z)
	AOA = clamp(AOA, -10, 20) # Cl v A chart only includes these angles
	var Cl := Cl_v_Alpha.sample((AOA + 10) / 30)
	
	var air_density := 0.5 # not simulating this nuh uh
	var velocity_squared = abs(Vector2(linear_velocity.x, linear_velocity.z).length() * Vector2(linear_velocity.x, linear_velocity.z).length())
	
	var lift : float = Cl * air_density * velocity_squared * wing_area
	%LiftForce.text = "Lift force: " + str(lift) + " N"
	
	#print("lift: ", lift, " gravity force: ", gravity_force, " sum: ", lift - gravity_force)
	return lift


## Brakes or applies thrust to try to meet the target speed given in kts.
func handle_speed(targ_speed : float) -> void:
	var speed = ms_to_kts(linear_velocity.length())
	
	var speed_diff : float = (targ_speed - speed) / 10
	thrust_lever = clamp(speed_diff, 0, 1)
	if targ_speed < 40: # TEMP
		thrust_lever = thrust_lever * .30 # Use maximum of 30% thrust when taxiing
	brake = abs(clamp(speed_diff, -1, 0)) * max_brake_force
	
	#print("Brake force: ", brake, "  thrust lever: ", thrust_lever)
