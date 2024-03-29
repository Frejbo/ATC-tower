extends State

@export var controller : AircraftController
@export var wait_timer : Timer
@export var comm_manager : communication_manager

func Enter() -> void:
	print("Doin")
	comm_manager.hide_all()
	controller.steering = 0
	controller.target_speed = 0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(func():
		comm_manager.set_visibility(comm_manager.TAXI_TO_RUNWAY, true)
		Game.chat.send_message(owner.callsign + " requesting taxi to runway")
		state_transition.emit(self, "static")
	)
	wait_timer.start()
