extends Label

func _process(_delta: float) -> void:
	text = "Landings: " + str(Game.landing_count)
