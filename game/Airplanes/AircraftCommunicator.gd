extends CanvasLayer

# Denna kod behöver byggas om i framtiden. Manuell och temporär.

class_name communication_manager

enum {
	TAXI_TO_STAND,
	TAXI_TO_RUNWAY,
	HOLD,
	TAKEOFF_CLEARANCE,
	LANDING_CLEARANCE,
	GO_AROUND,
	CONTINUE_APPROACH,
	LINE_UP
}
@export var taxi_to_stand : Button
@export var taxi_to_runway : Button
@export var hold : Button
@export var takeoff_clearance : Button
@export var landing_clearance : Button
@export var go_around : Button
@export var continue_approach : Button
@export var line_up : Button

#func _enter_tree() -> void:
	#hide_all()

func hide_all() -> void:
	taxi_to_stand.hide()
	taxi_to_runway.hide()
	hold.hide()
	takeoff_clearance.hide()
	landing_clearance.hide()
	go_around.hide()
	continue_approach.hide()
	line_up.hide()

func set_visibility(comm, available : bool) -> void:
	match comm:
		TAXI_TO_STAND:
			taxi_to_stand.visible = available
		TAXI_TO_RUNWAY:
			taxi_to_runway.visible = available
		HOLD:
			hold.visible = available
		TAKEOFF_CLEARANCE:
			takeoff_clearance.visible = available
		LANDING_CLEARANCE:
			landing_clearance.visible = available
		GO_AROUND:
			go_around.visible = available
		CONTINUE_APPROACH:
			continue_approach.visible = available
		LINE_UP:
			line_up.visible = available
