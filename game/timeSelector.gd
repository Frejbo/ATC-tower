extends VBoxContainer

enum types {HOUR, MINUTE}

@export var type : types 
@export var min_value : float = 0
@export var max_value : float = 23
@export var steps : float = 1
@export var increase_button : BaseButton
@export var decrease_button : BaseButton
@export var label : Label

func _ready() -> void:
	increase_button.pressed.connect(increase)
	decrease_button.pressed.connect(decrease)
	
	if type == types.HOUR:
		label.text = str(Time.get_time_dict_from_system().hour)
	if type == types.MINUTE:
		label.text = str(Time.get_time_dict_from_system().minute)
	
	check()

func increase() -> void:
	label.text = str(label.text.to_int() + steps)
	check()

func decrease() -> void:
	label.text = str(label.text.to_int() - steps)
	check()

func check() -> void:
	var val := label.text.to_int()
	if val > max_value:
		label.text = str(min_value)
	if val < min_value:
		label.text = str(max_value)
	label.text = label.text.pad_zeros(2)
