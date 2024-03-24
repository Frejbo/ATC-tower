extends State

@export var controller : AircraftController
@export var landing_rate_ms : float = .2
@export var flare_degrees : float = 3
@export var comm_manager : communication_manager
@export var behaviour_FSM : FiniteStateMachine

var is_in_flare : bool = false
var flare_elapsed_time : float = 0
var before_flare_angle : float

func Enter() -> void:
	is_in_flare = false
	controller.add_lift_force = false
	comm_manager.hide_all()
	comm_manager.set_visibility(comm_manager.LANDING_CLEARANCE, true)
	comm_manager.set_visibility(comm_manager.GO_AROUND, true)
	comm_manager.set_visibility(comm_manager.CONTINUE_APPROACH, true)
	
	Game.chat.send_message("On final runway 21.", owner.callsign)

func Physics_update(delta: float) -> void:
	
	
	if controller.is_on_ground():
		print("Touchdown")
		state_transition.emit(self, "decelerate")
		return
	
	if controller.global_position.y < 30 and not behaviour_FSM.landing_clearance:
		# Go around
		state_transition.emit(self, "go around")
		return
	
	if is_in_flare:
		flare_elapsed_time += delta
		
		controller.global_rotation_degrees.z = lerp(before_flare_angle, flare_degrees, ease(flare_elapsed_time/3, -2.5))
		controller.linear_velocity.y = lerp(-tan(deg_to_rad(3)) * controller.kts_to_ms(140), -landing_rate_ms, ease(flare_elapsed_time/4, -2.5))
		return
	
	
	# On approach
	if controller.global_position.y < 10:
		# Initiate flare
		controller.target_speed = 120
		before_flare_angle = controller.global_rotation_degrees.x
		is_in_flare = true
		
		comm_manager.hide_all()
		
		return
	
	controller.linear_velocity = Vector3(controller.kts_to_ms(140), -tan(deg_to_rad(3)) * controller.kts_to_ms(140), 0).rotated(Vector3(0, 1, 0), controller.global_rotation.y)
	controller.target_speed = 140
