extends Camera3D

@onready var default_rotation := rotation_degrees
@export var max_offset_degrees := Vector2(5, 5)
@export var follow_speed : float = 3
@export var invert : bool = false

func _process(delta: float) -> void:
	# Move the camera a bit when the mouse moves in main menu
	# Calculate mouse position on screen in percentage. left top = Vector2(-1, -1), right bottom = Vector2(1, 1). Middle of screen = Vector2(0, 0)
	var centered_mouse_pos = Vector2(
		clamp(get_viewport().get_mouse_position().x, 0, get_viewport().size.x),
		clamp(get_viewport().get_mouse_position().y, 0, get_viewport().size.y)
	) - get_viewport().size/2.0
	var percentage_position : Vector2 = centered_mouse_pos / (get_viewport().size/2.0)
	
	if invert: percentage_position *= -1
	
	# Set rotation
	rotation_degrees.y = lerpf(rotation_degrees.y, percentage_position.x * max_offset_degrees.x + default_rotation.y, delta * follow_speed)
	rotation_degrees.x = lerpf(rotation_degrees.x, percentage_position.y * max_offset_degrees.y + default_rotation.x, delta * follow_speed)
