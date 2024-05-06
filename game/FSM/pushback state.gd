extends State

@export var controller : AircraftController
@export var comm_manager : communication_manager
@export var push_length : float = 50
var start_pos : Vector3

func Enter() -> void:
	start_pos = controller.global_position

func Physics_update(_delta) -> void:
	if controller.global_position.distance_to(start_pos) > push_length:
		# Stop push
		state_transition.emit(self, "static")
		await get_tree().create_timer(10).timeout
		Game.chat.send_message(owner.callsign + " requesting taxi")
		comm_manager.set_visibility(comm_manager.TAXI_TO_RUNWAY, true)
	else:
		controller.apply_force(Vector3(0, 0, -controller.mass*2))
		#controller.linear_velocity = Vector3(-10, 0, -10)

