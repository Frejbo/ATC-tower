@tool # If you remove this @tool, try to restart godot and see if it still works
extends Node

var taxiwayManager : Node
var taxiways := {}
var AircraftManager : Node
var stands := {}
var active_approach : approach_guidance
var chat : Chat
var runway : Runway
var landing_count : int = 0
var takeoff_count : int = 0
@onready var time : float

func _ready() -> void:
	var total_seconds = Time.get_time_dict_from_system().hour * 3600 + Time.get_time_dict_from_system().minute * 60 + Time.get_time_dict_from_system().second
	time = total_seconds / 3600.0

func _process(delta: float) -> void:
	time += delta * 0.00027777777
