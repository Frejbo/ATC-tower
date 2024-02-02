extends VBoxContainer

@export var scene : PackedScene

func _ready() -> void:
	Game.AircraftManager.list_updated.connect(update_aircraft_list)

func update_aircraft_list(list : Array[Aircraft]) -> void:
	for airplane : Aircraft in list:
		var strip := scene.instantiate()
		if has_node(airplane.callsign):
			strip = get_node(airplane.callsign)
		else:
			add_child(strip)
		
		# Set values
		strip.name = airplane.callsign
		strip.callsign = airplane.callsign
