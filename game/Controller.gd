extends Node

signal update_aircraft_list

var aircrafts : Array[aircraft]:
	set(val):
		aircrafts = val
		update_aircraft_list.emit(aircrafts)


