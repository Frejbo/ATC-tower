extends Button

@export var callsign : String:
	set(val):
		callsign = val
		print("setting")
		%callsign.text = val
@export var arriving_departing : String:
	set(val):
		arriving_departing = val
		%arriving_departing.text = val
@export var aircraft_type : String:
	set(val):
		aircraft_type = val
		%aircraft_type.text = val
@export var status : String:
	set(val):
		status = val
		%status.text = val
