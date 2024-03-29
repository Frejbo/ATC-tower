extends Camera3D

## The FOV when zoomed at maximum
@export_range(5, 100) var max_zoom = 10
## The FOV when not zoomed in
@export_range(5, 100) var min_zoom = 60
@export_range(1, 10) var scroll_snap = 5

func _input(event: InputEvent) -> void:
	if not (event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out")): return # Prevent creating unnecessary tweens.
	var tween = get_tree().create_tween()
	tween.tween_property(self, "fov", clamp(fov + Input.get_axis("zoom_in", "zoom_out") * scroll_snap, max_zoom, min_zoom), 0.25) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
