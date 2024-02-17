extends FiniteStateMachine


func taxi(route : Curve3D):
	if not states.has("taxi"):
		printerr("taxi state was not found in AircraftBehaviourManager.")
		return
	states.get("taxi").taxi_path = route
	
	if current_state.name == "static":
		change_state(current_state, "taxi")
