extends Node3D

@export var path : Path3D
@export var connection_sizes : Array[float]:
	set(val):
		connection_sizes = val
		for i in val.size():
			if not has_node(str(i)): continue
			var area : Area3D = get_node(str(i))
			var coll_shape : SphereShape3D = area.get_child(0).shape
			coll_shape.radius = val[i]
@export var default_connection_size : int = 1

func _on_path_3d_curve_changed() -> void:
	var areas_to_keep : Array[Area3D]
	# Add areas for every point in path curve
	for p_idx : int in path.curve.point_count:
		var p_pos := path.curve.get_point_position(p_idx)
		if has_node(str(p_idx)):
			# Move existing area
			get_node(str(p_idx)).position = p_pos
		else:
			# Add area
			var area := Area3D.new()
			area.name = str(p_idx)
			area.position = p_pos
			add_child(area)
			var coll := CollisionShape3D.new()
			var shape := SphereShape3D.new()
			shape.radius = default_connection_size
			if connection_sizes.size() <= p_idx: shape.radius = connection_sizes[p_idx]
		areas_to_keep.append(get_node(str(p_idx)))
	
	# Remove areas not in areas_to_keep
	for child : Node in get_children():
		if not child is Area3D: continue
		if areas_to_keep.has(child): continue
		child.queue_free()
	
	# set areas export array so we can change size
	var area_count := 0
	for area in get_children():
		if not area is Area3D: continue
		area_count += 1
	while area_count > connection_sizes.size():
		connection_sizes.append(default_connection_size)
	while area_count < connection_sizes.size():
		connection_sizes.pop_back()
