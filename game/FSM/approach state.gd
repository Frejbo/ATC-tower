extends State

@export var controller : AircraftController
@export var landing_rate_ms : float = .2
@export var flare_degrees : float = 3
@export var go_around_altitude : float = 100
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
	
	await get_tree().process_frame # Wait 1 frame to prevent aircrafts on ground from reporting approach. This is due to approach is the initial state in the FSM and it takes a frame for it to change to static if on ground.
	if behaviour_FSM.current_state == self:
		Game.chat.send_message(owner.callsign + " is on final runway 21.")


var warned_about_short_final := false
func Physics_update(delta: float) -> void:
	if controller.is_on_ground():
		print("Touchdown")
		state_transition.emit(self, "decelerate")
		return
	
	if controller.global_position.y < go_around_altitude and not warned_about_short_final and not behaviour_FSM.landing_clearance:
		Game.chat.send_message(owner.callsign + " is on short final.")
		warned_about_short_final = true
	
	if controller.global_position.y < go_around_altitude and not behaviour_FSM.landing_clearance:
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
