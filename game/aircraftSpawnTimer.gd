extends Timer

@export var aircraftManager : Node


#const callsigns := ["SAS1802", "SAS434", "SAS71L", "SAS430", "SAS86L", "SAS161", "SAS43E", "SAS446", "SAS169", "SAS2051"]
var callsign : String:
	get:
		return "SAS" + str(randi_range(0, 9999)) # Randomize callsign

func _ready() -> void:
	# Spawn first aircraft
	await get_tree().create_timer(2).timeout
	aircraftManager.spawn(callsign)
	
	# Connect
	timeout.connect(func():
		print("Spawning ", callsign)
		aircraftManager.spawn(callsign)
		randomize()
		start(randi_range(50, 240))
	)
