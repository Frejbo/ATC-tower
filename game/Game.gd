@tool # If you remove this @tool, try to restart godot and see if it still works
extends Node

var taxiwayManager : Node
var taxiways := {}
var AircraftManager : Node
var stands := {}
var active_approach : approach_guidance
var chat : Chat
var runway : Runway
@onready var time : float

var landing_count : int = 0
var takeoff_count : int = 0

func _process(delta: float) -> void:
	time += delta * 0.00027777777
