extends Timer

@export var aircraftManager : Node


const callsigns := ["SAS1802", "SAS434", "SAS71L", "SAS430", "SAS86L", "SAS161", "SAS43E", "SAS446", "SAS169", "SAS2051"]


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	aircraftManager.spawn(callsigns.pick_random())
	timeout.connect(func():
		aircraftManager.spawn(callsigns.pick_random())
		)
