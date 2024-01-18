extends Node

@export var body : aircraft:
	set(val):
		body = val
		$Path3D/RemoteTransform3D.remote_path = val.get_path()

var taxiways = ["A", "B", "C"]

var path : Curve3D = Curve3D.new()
func _ready():
	$Path3D/RemoteTransform3D.remote_path = body.get_path()
	for taxiway_name in taxiways:
		var taxiway_curve : Curve3D = Game.taxiways.get_node(taxiway_name).curve
		for point_idx in taxiway_curve.point_count:
			$Path3D.curve.add_point(taxiway_curve.get_point_position(point_idx))

func _process(delta):
	print(.1 * delta)
	$Path3D/PathFollow3D.progress_ratio += .2 * delta
	body.position = $Path3D/PathFollow3D.position
	print($Path3D/PathFollow3D.position)
