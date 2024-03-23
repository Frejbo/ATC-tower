extends Area3D

class_name Runway

func _enter_tree() -> void:
	Game.runway = self

@onready var takeoff_points := {
		"Y":%Y,
		"F":%F,
		"E":%E
	}
