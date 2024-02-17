extends Node
class_name FiniteStateMachine

var states : Dictionary = {}
var current_state : State

@export var initial_state : State

func _ready() -> void:
	for child : Node in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_update(delta)

func change_state(source_state : State, new_state_name : String) -> void:
	if source_state != current_state:
		printerr("Invalid change_state trying from: ", source_state.name, " but currently in: ", current_state.name)
		return
	
	var new_state : State = states.get(new_state_name.to_lower())
	if !new_state:
		printerr("New state is empty")
	
	current_state.Exit()
	print("Switching state to: ", new_state.name)
	new_state.Enter()
	
	current_state = new_state
