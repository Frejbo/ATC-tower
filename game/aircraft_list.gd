extends VBoxContainer

@export var scene : PackedScene

func _enter_tree() -> void:
	Controller.update_aircraft_list.connect(update_aircraft_list)

func update_aircraft_list(list : Array[aircraft]) -> void:
	for airplane : aircraft in list:
		var strip := scene.instantiate()
		if has_node(airplane.callsign):
			strip = get_node(airplane.callsign)
		else:
			add_child(strip)
		
		# Set values
		strip.name = airplane.callsign
		strip.callsign = airplane.callsign
