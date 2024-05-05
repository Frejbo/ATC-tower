@tool
extends Node3D

@export var hour_label : Label
@export var minute_label : Label
@export var sky : Node

func update_time() -> void:
	var total_seconds = hour_label.text.to_int() * 3600 + minute_label.text.to_int() * 60
	sky.day_time = total_seconds / 3600.0
