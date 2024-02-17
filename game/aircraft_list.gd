extends VBoxContainer

@export var scene : PackedScene

func _ready() -> void:
	Game.AircraftManager.list_updated.connect(update_aircraft_list)
	update_aircraft_list(Game.AircraftManager.aircrafts)

func update_aircraft_list(dict : Dictionary) -> void:
	for airplane : Aircraft in dict.values():
		var strip := scene.instantiate()
		if has_node(airplane.callsign):
			strip = get_node(airplane.callsign)
		else:
			add_child(strip)
		
		# Set values
		strip.name = airplane.callsign
		strip.callsign = airplane.callsign
