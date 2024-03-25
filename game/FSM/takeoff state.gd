extends State

@export var controller : AircraftController
@export var climb_pitch : float = 15
@export var comm_manager : communication_manager

func Enter() -> void:
	comm_manager.hide_all()
	
	controller.target_speed = 200
	controller.add_lift_force = true

var current_pitch_vel : float = 0
func Physics_update(_delta : float) -> void:
	
	if controller.global_position.y > 80:
		climb_pitch = 5 # Start leveling off to begin acceleration
	
	if controller.get_speed_kts() > 130: # Start rotating
		var deg_vel : float = lerpf(-.1, 0.0, abs(controller.rotation_degrees.z) / climb_pitch)
		current_pitch_vel = lerpf(current_pitch_vel, deg_vel, .01)
		controller.angular_velocity.z = current_pitch_vel
	
	if controller.global_position.y > 500:
		print(owner.callsign, " passed 500m y, removing.")
		owner.queue_free()
	
	# Something in FlightPhysics doesn't allow the plane to remain airborne at some speeds, this forces the aircraft to not fall too much.
	if controller.linear_velocity.y < -2:
		controller.linear_velocity.y = -2
