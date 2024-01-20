extends Node

@export var body : aircraft:
	set(val):
		body = val
		$Path3D/RemoteTransform3D.remote_path = val.get_path()

@export var route = ["A", "B", "C"]

var path : Curve3D = Curve3D.new()

func _ready():
	$Path3D/RemoteTransform3D.remote_path = body.get_path()
	
	var pos = body.global_position
	for taxiway_name in route:
		var taxiway_curve : Curve3D = Game.taxiways.get_node(taxiway_name).curve
		
		#for point in find_required_points_on_curve(taxiway_curve, pos):
			#$Path3D.curve.add_point(point)
			#pos = point
		
		for point_idx in taxiway_curve.point_count:
			$Path3D.curve.add_point(taxiway_curve.get_point_position(point_idx))

## Uses pathfinding to find the path on the given taxiway. From the point which is closest to "closest_start", to the point which is closest to "closest_end". The aircraft need to go via the returned points before going to "closest_end" point.
#func find_required_points_on_curve(curve : Curve3D, closest_start : Vector3, goal_taxiway : taxiway) -> Array[Vector3]:
	#var baked_curve : Curve3D
	#for p in curve.get_baked_points():
		#baked_curve.add_point(p)
	#var start : int = baked_curve.get_closest_point(closest_start)
	#var end : int = baked_curve.get_baked_points(closest_end)

func _process(delta):
	print(.1 * delta)
	$Path3D/PathFollow3D.progress += 20 * delta
	body.position = $Path3D/PathFollow3D.position
	print($Path3D/PathFollow3D.position)
