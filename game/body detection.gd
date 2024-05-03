extends Area3D

@export var main_menu : PackedScene

func _on_area_entered(area: Area3D) -> void:
	if area.owner is Aircraft:
		print("Game over, crashed")
		OS.alert("Some aircrafts collided!")
		get_tree().change_scene_to_packed(main_menu)
