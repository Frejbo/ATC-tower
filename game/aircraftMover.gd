extends Node

@export var body : aircraft:
	set(val):
		body = val
		if not val.is_inside_tree():
			await val.tree_entered
		$Path3D/RemoteTransform3D.remote_path = val.get_path()
@export var goal_position : Vector3

@export var route : Array[String]

var path : Curve3D = Curve3D.new()

func _ready():
	if not Game.taxiways.can_be_read:
		await Game.taxiways.ready_to_be_read
	$Path3D/RemoteTransform3D.remote_path = body.get_path()
	
	var detailed_taxi_route := {
		#"E":{"start_point":3, "passing_points":[3, 4, 5, 6, 7, 8], "end_point":8},
		#"D":{"start_point":0, "passing_points":[0, 1, 2], "end_point":2},
		#"A":{"start_point":8, "passing_points":[8, 7, 6, 5, 4, 3], "end_point":3}
	}
	
	# Calculates the destination point on each taxiway, meaning the last point they will pass on each taxiway before transitioning to next.
	var current_point = closest_point(body.global_position, Game.taxiways.get_node(route[0]).curve)
	var taxiway_destinations : Array = []
	for taxiway_idx in range(route.size()):
		var tw : taxiway = Game.taxiways.get_node(route[taxiway_idx])
		if route.size()-1 >= taxiway_idx+1: # Next destination is a taxiway
			# Find next point which has connection to next taxiway
			var connection_point = find_closest_connecting_point(tw, current_point, route[taxiway_idx+1])
			taxiway_destinations.append({"taxiway":tw, "last_point":connection_point})
			
			# Sätt current_point till punkten man startar på vid nästa taxiway
			current_point = closest_point(tw.curve.get_point_position(taxiway_destinations.back()["last_point"]), Game.taxiways.get_node(route[taxiway_idx+1]).curve)
		else:
			# Find closest point to goal pos on latest taxiway. Arrival point.
			# TODO I think this will require a tesselated or baked curve to work properly
			var closest_point_to_goal : int = closest_point(goal_position, tw.curve)
			taxiway_destinations.append({"taxiway":tw, "last_point":closest_point_to_goal})
	
	print("Taxiway destinations: ", taxiway_destinations)
	
	
	# Loop through taxiway_destinations, convert and add them and everything neccesary to detailed_taxi_route
	current_point = closest_point(body.global_position, taxiway_destinations[0]["taxiway"].curve)
	for taxi : Dictionary in taxiway_destinations:
		# fill from current point to last_point...
		var details := {"start_point":current_point, "passing_points":[], "end_point":taxi["last_point"]}
		path.add_point(
			taxi["taxiway"].curve.get_point_position(current_point),
			taxi["taxiway"].curve.get_point_in(current_point),
			taxi["taxiway"].curve.get_point_out(current_point))
		
		while current_point != taxi["last_point"]:
			if current_point > taxi["last_point"]:
				current_point -= 1
			elif current_point < taxi["last_point"]:
				current_point += 1
			
			path.add_point(
				taxi["taxiway"].curve.get_point_position(current_point),
				taxi["taxiway"].curve.get_point_in(current_point),
				taxi["taxiway"].curve.get_point_out(current_point))
			details["passing_points"].append(current_point)
		
		detailed_taxi_route[taxi["taxiway"].name] = details
		
		# om det här är slutet, hitta inte en transition:
		if taxi["taxiway"] == taxiway_destinations.back()["taxiway"]:
			continue
		
		
		var next_taxiway_destination : Dictionary = taxiway_destinations[taxiway_destinations.find(taxi)+1]
		var available_transitions : Array[taxiway] = get_transitions_from_to(taxi["taxiway"], current_point, next_taxiway_destination["taxiway"].name)
		
		# find and fill transition
		var transition : taxiway = choose_transition(available_transitions, next_taxiway_destination["last_point"])
		for i in transition.curve.point_count:
			path.add_point(
				transition.curve.get_point_position(i),
				transition.curve.get_point_in(i),
				transition.curve.get_point_out(i))
		
		# set current_point to start_point of new taxiway
		current_point = transition.get_meta("to_point")
	
	
	print(detailed_taxi_route)
	$Path3D.curve = path


func choose_transition(available_transitions : Array[taxiway], last_point_on_target_tw : int) -> taxiway:
	var transition_end_points : Array[int] = []
	for transition : taxiway in available_transitions:
		transition_end_points.append(transition.get_meta("to_point"))
	var closest_end_point : int = closest_number(last_point_on_target_tw, transition_end_points)
	var chosen_transition : taxiway
	for transition : taxiway in available_transitions:
		if transition.get_meta("to_point") == closest_end_point:
			chosen_transition = transition
	return chosen_transition

func set_path_from_positions(positions : Array[Vector3]) -> void:
	for pos in positions:
		path.add_point(pos)
	$Path3D.curve = path

## Returning closest available point with a transition to the given destination taxiway.
func find_closest_connecting_point(tw : taxiway, origin_point : int, destination_taxiway_name : String) -> int:
	var connecting_points : Array[int] = []
	# Search every point in the taxiway
	for point in tw.curve.point_count:
		print("Checking point ", point, " on taxiway ", tw.name)
		# If point has transition to destination_taxiway, add to connecting_points.
		if has_transition_to(tw, point, destination_taxiway_name):
			connecting_points.append(point)
			print("Transition found!")
	
	if connecting_points.is_empty():
		printerr("Couldn't go from ", tw.name, " to ", destination_taxiway_name)
	
	# Return the connecting point which is closest to origin_point.
	return closest_number(origin_point, connecting_points)

## Finding the number that is closest to "num" in an array of ints. If the array contains 2 points which area exactly the same distance, it will return the point which is first in the array.
func closest_number(num : int, search : Array[int]) -> int:
	if search.is_empty():
		printerr("Search input was ", search, ", it has to be something. (in closest_numer(), aircraftMover.gd)")
	var closest : int = -1
	var closest_delta : int = abs(search[0]-num)
	for i in search:
		if closest == -1 or abs(i - num) < closest_delta:
			closest_delta = abs(i - num)
			closest = i
	print("Closest number to ", num, " in: ", search, " is ", closest)
	return closest

## Returns the closest curve point index to position
func closest_point(position : Vector3, curve : Curve3D) -> int:
	var points : Array[Vector3] = []
	for point : int in curve.point_count:
		points.append(curve.get_point_position(point))
	
	var closest_pos
	var closest_distance : float
	for p : Vector3 in points:
		var current_distance := p.distance_to(position)
		if closest_pos == null or current_distance < closest_distance:
			closest_pos = p
			closest_distance = current_distance
	print(closest_distance)
	return points.find(closest_pos)

## Checks the given taxiway and returns true if the given point has a transition to the "to_point".
func has_transition_to(start_taxiway : taxiway, from_point : int, end_taxiway_name : String, to_point : int = -1) -> bool:
	for node in start_taxiway.get_children():
		if not node.has_meta("from"): continue
		if not node.get_meta("from_point") == from_point: continue
		if not node.get_meta("to") == end_taxiway_name: continue
		if to_point >= 0:
			if not node.get_meta("to_point") == to_point: continue
		return true
	return false

## Get all transitions going from point x on taxiway y towards taxiway named z
func get_transitions_from_to(from_taxiway : taxiway, from_point, target_taxiway_name : String) -> Array[taxiway]:
	var available_transitions : Array[taxiway] = []
	for transition in from_taxiway.get_children():
		if not transition.has_meta("from_point"): continue
		if not transition.get_meta("from_point") == from_point: continue
		if not transition.get_meta("to") == target_taxiway_name: continue
		available_transitions.append(transition)
	return available_transitions

func _process(delta):
	$Path3D/PathFollow3D.progress += 200 * delta
	body.position = $Path3D/PathFollow3D.position
