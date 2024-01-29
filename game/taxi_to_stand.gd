extends Button

@export var stand : LineEdit
@export var route : LineEdit

signal taxi_to_stand

func _on_pressed() -> void:
	if not Game.stands.has(stand.text): return
	taxi_to_stand.emit(Game.stands.get(stand.text), route.get_route())