extends FiniteStateMachine

@export var controller : AircraftController

var landing_clearance := false
var takeoff_point : Marker3D
var takeoff_clearance := false
