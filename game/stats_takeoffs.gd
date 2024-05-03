extends Label

func _process(_delta: float) -> void:
	text = "Takeoffs: " + str(Game.takeoff_count)
