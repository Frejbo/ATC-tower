@tool # If you remove this @tool, try to restart godot and see if it still works
extends Node

var taxiwayManager : Node
var taxiways := {}
var AircraftManager : Node
var stands := {}
var active_approach : approach_guidance
