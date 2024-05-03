extends Button

@export var main_game : PackedScene

func _pressed() -> void:
	get_tree().change_scene_to_packed(main_game)
	
	var total_seconds = %hour.text.to_int() * 3600 + %minute.text.to_int() * 60
	Game.time = total_seconds / 3600.0
