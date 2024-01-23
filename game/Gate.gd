@tool
extends Marker3D

@export var gate_name : String:
	set(text):
		if text == "":
			name = "Gate"
			gate_name = ""
			return
		name = text.to_upper()
		gate_name = name

@export var taxiway_in : taxiway

func _enter_tree() -> void:
	Game.stands[gate_name] = self
