extends Node
class_name State

signal state_transition

func _enter_tree() -> void:
	set_physics_process(false)

func Enter() -> void:
	set_physics_process(true)

func Exit() -> void:
	set_physics_process(false)

func Update(_delta : float) -> void:
	pass

func Physics_update(_delta : float) -> void:
	pass
