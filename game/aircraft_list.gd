extends VBoxContainer

@export var scene : PackedScene

func _ready() -> void:
	Game.AircraftManager.list_updated.connect(update_aircraft_list)
	print(Game.AircraftManager)

func update_aircraft_list(list : Array[aircraft]) -> void:
	print(list)
	for airplane : aircraft in list:
		var strip := scene.instantiate()
		if has_node(airplane.callsign):
			strip = get_node(airplane.callsign)
		else:
			add_child(strip)
		
		# Set values
		strip.name = airplane.callsign
		strip.callsign = airplane.callsign
