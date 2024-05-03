extends Label



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dt_dict := Time.get_datetime_dict_from_system()
	text = "METAR: ESGG "+str(dt_dict.day)+"0950Z 10011KT 9999 OVC050 17/02 Q1026 NOSIG"
