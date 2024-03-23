extends FiniteStateMachine

@export var controller : AircraftController

var hold := false:
	set(val):
		if val:
			Game.chat.send_message("Holding position.")
		else:
			Game.chat.send_message("Continuing taxiing.")
		controller.freeze = val
		hold = val
