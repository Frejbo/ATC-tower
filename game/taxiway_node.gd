@tool
extends Path3D

class_name taxiway

@export var taxiway_name : String:
	set(text):
		Game.taxiways.erase(name)
		if text == "":
			name = "taxiway"
			taxiway_name = ""
			return
		name = text.to_upper()
		taxiway_name = name
		Game.taxiways[name] = self

@export var vacate : Array[int]

func _get_configuration_warnings() -> PackedStringArray:
	var warning : PackedStringArray = []
	if Game.taxiways.get(name, self) != self:
		warning.append("There is another taxiway with the same name as this one (" + name + ").")
	return warning

@export var allow_y : bool = false

@export var default_connection_size : float = 30
@export var connection_sizes : Array[float]:
	set(val):
		connection_sizes = val
		for i in val.size():
			if not has_node(str(i)): return
			var area : Area3D = get_node(str(i))
			var coll : SphereShape3D = area.get_child(0).shape
			coll.radius = val[i]

@export var ignore_areas : bool = false

@export_category("taxiline")
@export var taxiline_material : StandardMaterial3D = preload("res://taxilines.tres")
@export var taxiline_shape : PackedVector2Array = [Vector2(0, 0), Vector2(-.5, .01), Vector2(.5, .01)]

var csg_debug_shape : CSGPolygon3D


func _on_curve_changed() -> void:
	if !curve: return
	if curve.point_count <= 1: return
	# Force y of every point to 0
	if not allow_y:
		for i in range(curve.point_count):
			var point = curve.get_point_position(i)
			if point.y != 0:
				curve.set_point_position(i, Vector3(point.x, 0, point.z))
			
			var point_in = curve.get_point_in(i)
			if point_in.y != 0:
				curve.set_point_in(i, Vector3(point_in.x, 0, point_in.z))
			
			var point_out = curve.get_point_out(i)
			if point_out.y  != 0:
				curve.set_point_out(i, Vector3(point_out.x, 0, point_out.z))
			
			if curve.get_point_tilt(i) != 0:
				curve.set_point_tilt(i, 0)
	
	if not ignore_areas:
		if area_update_cooldown_timer.is_stopped():
			update_areas()
			area_update_cooldown_timer.start()

func _ready() -> void:
	curve_changed.connect(_on_curve_changed)

func clean_up_nodes() -> void:
	for child in get_children():
		if child.is_in_group("dynamic_taxiline"):
			child.free()

func _exit_tree() -> void:
	clean_up_nodes()
	Game.taxiways.erase(name)
	PhysicsServer3D.set_active(false)

var area_update_cooldown_timer : Timer
func _enter_tree() -> void:
	Game.taxiways[name] = self
	clean_up_nodes()
	
	if not ignore_areas:
		area_update_cooldown_timer = Timer.new()
		area_update_cooldown_timer.wait_time = .25
		area_update_cooldown_timer.one_shot = true
		area_update_cooldown_timer.timeout.connect(update_areas)
		add_child(area_update_cooldown_timer)
		area_update_cooldown_timer.owner = self
		area_update_cooldown_timer.add_to_group("dynamic_taxiline")
	
	
	add_to_group("taxiway")
	
	# Add taxiline
	csg_debug_shape = CSGPolygon3D.new()
	csg_debug_shape.polygon = taxiline_shape
	csg_debug_shape.mode = CSGPolygon3D.MODE_PATH
	csg_debug_shape.path_simplify_angle = .1
	csg_debug_shape.path_interval = 5
	csg_debug_shape.material = taxiline_material
	csg_debug_shape.add_to_group("dynamic_taxiline")
	add_child(csg_debug_shape)
	csg_debug_shape.owner = self
	csg_debug_shape.path_node = ".."
	csg_debug_shape.position = -position
	
	if not ignore_areas:
		PhysicsServer3D.set_active(true)
		update_areas()
		for i in range(2): # wait 2 physics frames to make sure areas has detected each other. (1 don't work)
			await Engine.get_main_loop().physics_frame
		connect_to_nearby()
		if Engine.is_editor_hint():
			PhysicsServer3D.set_active(false)

func _notification(what: int) -> void: # Temporarily reactivate the PhysisServer to allow taxiways to connect.
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		PhysicsServer3D.set_active(true)
		for i in range(2): # wait 2 physics frames to make sure areas has detected each other. (1 don't work)
			await Engine.get_main_loop().physics_frame
		if Engine.is_editor_hint():
			PhysicsServer3D.set_active(false)

func create_area(pos : Vector3, area_name : String) -> Area3D:
	if ignore_areas: return
	
	var area := Area3D.new()
	area.position = pos
	add_child(area)
	area.owner = self
	area.add_to_group("dynamic_taxiline")
	area.name = area_name
	
	var coll := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	if area.name.to_int() < connection_sizes.size():
		shape.set_radius(connection_sizes[area.name.to_int()])
	else:
		shape.set_radius(default_connection_size)
	coll.shape = shape
	area.add_child(coll)
	coll.owner = self
	coll.add_to_group("dynamic_taxiline")
	
	area.area_shape_exited.connect(_area_exited)
	
	return area


func update_areas() -> void:
	if !curve: return
	var curve_points : Array[int] = []
	for i in curve.point_count:
		curve_points.append(i)
	
	for area in get_children():
		if not area is Area3D: continue
		if not area.owner == self: continue
		
		if area.name.to_int() > curve.point_count -1:
			# Point on curve has been deleted, remove corresponding area.
			area.queue_free()
			continue
		
		if curve_points.has(area.name.to_int()):
			# Area and curve point exists and correlate. In case their positions don't align, fix it.
			area.position = curve.get_point_position(area.name.to_int())
			curve_points.erase(area.name.to_int())
			continue
		
		print("I don't think this should happen ", area.name)
	
	for point in curve_points:
		# Point on curve exists but area wasn't found. Add area.
		create_area(curve.get_point_position(point), str(point))
		connection_sizes.append(default_connection_size)
	
	# set areas export array so we can change size
	var area_count := 0
	for area in get_children():
		if not area is Area3D: continue
		area_count += 1
	while area_count > connection_sizes.size():
		connection_sizes.append(default_connection_size)
	while area_count < connection_sizes.size():
		connection_sizes.pop_back()
	
	connect_to_nearby()


## Gets all of the placed points
func get_points() -> Array[Vector3]:
	var points : Array[Vector3] = []
	for i in curve.point_count:
		points.append(curve.get_point_position(i-1))
	return points

func _area_exited(_a, _b, _c, _d) -> void:
	connect_to_nearby()

func connect_to_nearby(exclude_taxiways : Array[taxiway] = [], recursion : bool = false) -> void:
# Check all areas on this taxiway
	var valid_transitioning_taxiways : Array[taxiway] = []
	var areas_to_check : Array[Area3D] = []
	for node : Node in get_children():
		if node is Area3D:
			if node.owner is taxiway:
				areas_to_check.append(node)
	
	for area : Area3D in areas_to_check:
		# Get overlapping areas, excluding areas belonging to this taxiway
		var overlapping_areas : Array[Area3D] = area.get_overlapping_areas().filter(
			func(a): return a.owner is taxiway)
		for overlapping in overlapping_areas:
			if overlapping.owner == self:
				overlapping_areas.erase(overlapping)
		
		# If no overlapping areas, continue and check next area on this taxiway
		if not overlapping_areas: continue
		
		# Create segway path which goes between this and all target taxiways.
		for target_area in overlapping_areas:
			# Create a curve for the transition
			var transition_curve := Curve3D.new()
			transition_curve.add_point(area.position)
			transition_curve.add_point(target_area.position)
			# define a name for the transition
			var transition_name = name+area.name+"-"+target_area.get_parent().name+target_area.name
			
			
			var transition_taxiway := taxiway.new()
			# Check if transition taxiway already exists, in that case move it and don't create a new.
			if has_node(transition_name):
				transition_taxiway = get_node(transition_name)
			else:
				transition_taxiway.name = transition_name
				transition_taxiway.ignore_areas = true
				transition_taxiway.add_to_group("dynamic_taxiline")
				add_child(transition_taxiway)
				transition_taxiway.owner = self
			transition_taxiway.set_meta("from", name)
			transition_taxiway.set_meta("to", target_area.get_parent().name)
			transition_taxiway.set_meta("from_point", area.name.to_int())
			transition_taxiway.set_meta("to_point", target_area.name.to_int())
			transition_taxiway.curve = transition_curve
			valid_transitioning_taxiways.append(transition_taxiway)
			
			# Update the other taxiway as well
			if target_area.get_parent() in exclude_taxiways: continue
			exclude_taxiways.append(self)
			if not recursion:
				target_area.get_parent().connect_to_nearby(exclude_taxiways, true)
			
	
	# Check for taxiways which is not in the valid_transitioning_taxiways list and remove them
	for transition_taxiway in get_children():
		if not transition_taxiway is taxiway: continue
		if valid_transitioning_taxiways.has(transition_taxiway): continue
		transition_taxiway.queue_free()
