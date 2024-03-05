extends State

@export var controller : AircraftController
@export var climb_pitch : float = 15

func Enter() -> void:
	controller.target_speed = 200
	controller.add_lift_force = true

var current_pitch_vel : float = 0
func Update(_delta : float) -> void:
	
	if controller.global_position.y > 80:
		climb_pitch = 5 # Start leveling off to begin acceleration
	
	if controller.get_speed_kts() > 130: # Start rotating
		var deg_vel : float = lerpf(-.1, 0.0, abs(controller.rotation_degrees.x) / climb_pitch)
		current_pitch_vel = lerpf(current_pitch_vel, deg_vel, .005)
		controller.angular_velocity.z = current_pitch_vel
