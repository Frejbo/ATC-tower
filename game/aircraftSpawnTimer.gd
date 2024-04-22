extends Timer

@export var aircraftManager : Node


#const callsigns := ["SAS1802", "SAS434", "SAS71L", "SAS430", "SAS86L", "SAS161", "SAS43E", "SAS446", "SAS169", "SAS2051"]
var callsign : String:
	get:
		return "SAS" + str(randi_range(0, 9999))

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	aircraftManager.spawn(callsign)
	timeout.connect(func():
		aircraftManager.spawn(callsign)
		)
