extends Button


@export var hold_label : String = "Hold position"
@export var resume_label : String = "Resume taxiing"
@export var controller : AircraftController

func _pressed() -> void:
	controller.force_hold = !controller.force_hold
	check_text()

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_VISIBILITY_CHANGED:
		#check_text()

func check_text() -> void:
	if controller.force_hold:
		Game.chat.send_tower_message(owner.callsign + " hold position.")
		Game.chat.send_message("Holding position, " + owner.callsign)
		text = resume_label
	else:
		Game.chat.send_tower_message(owner.callsign + " continue taxiing.")
		Game.chat.send_message("Continuing, " + owner.callsign)
		text = hold_label
