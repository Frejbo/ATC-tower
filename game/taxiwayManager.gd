@tool
extends Node3D

@export var show_taxiways : bool:
	set(val):
		show_taxiways = val
		for node in get_children():
			if not node is taxiway: continue
			node.visible = val 

func _enter_tree():
	if Engine.is_editor_hint(): return
	Game.taxiwayManager = self
	
	for i in range(3):
		await get_tree().physics_frame
	can_be_read = true

signal ready_to_be_read
var can_be_read : bool = false:
	set(val):
		can_be_read = val
		if val:
			ready_to_be_read.emit()
