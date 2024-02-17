extends State

@export var controller : AircraftController
@export var landing_rate_ms : float = .5
@export var flare_degrees : float = 4

var is_in_flare : bool = false
var flare_elapsed_time : float = 0
var before_flare_angle : float

func Enter() -> void:
	is_in_flare = false

func Physics_update(delta: float) -> void:
	if controller.is_on_ground():
		print("Touchdown")
		state_transition.emit(self, "decelerate")
		return
	
	if is_in_flare:
		flare_elapsed_time += delta
		
		#var tween = create_tween()
		#tween.interpolate_value(before_flare_angle, -5, flare_elapsed_time, 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		controller.global_rotation_degrees.x = lerp(before_flare_angle, -flare_degrees, ease(flare_elapsed_time/3, -2.5))
		controller.linear_velocity.y = lerp(-tan(deg_to_rad(3)) * controller.kts_to_ms(140), -landing_rate_ms, ease(flare_elapsed_time/4, -2.5))
		return
	
	# On approach
	if controller.global_position.y < 10:
		# Initiate flare
		controller.target_speed = 130
		before_flare_angle = controller.global_rotation_degrees.x
		is_in_flare = true
		return
	
	controller.linear_velocity = Vector3(0, -tan(deg_to_rad(3)) * controller.kts_to_ms(140), controller.kts_to_ms(140)).rotated(Vector3(0, 1, 0), controller.global_rotation.y)
	controller.target_speed = 140
