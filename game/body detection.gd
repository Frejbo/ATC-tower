extends Area3D


func _on_area_entered(area: Area3D) -> void:
	if area.owner is Aircraft:
		print("Game over, crashed")
		OS.alert("Some aircrafts collided!")
