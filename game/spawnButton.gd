extends VBoxContainer




func _on_button_pressed() -> void:
	if %callsign_to_spawn.text == "": return
	Game.AircraftManager.spawn(%callsign_to_spawn.text)
	%callsign_to_spawn.text = ""
