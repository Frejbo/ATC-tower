extends VBoxContainer
class_name Chat

@export var tower_text_color : Color
@export var aircraft_text_color : Color
@export var info_overlay : Color = Color(0, 0, 0, .75)


func _enter_tree() -> void:
	Game.chat = self

func send_message(message : String, sender : String = "", include_time : bool = true, text_color : Color = aircraft_text_color) -> void:
	var hbox := HBoxContainer.new()
	hbox.name = "message"
	add_child(hbox)
	
	if include_time:
		var timeLabel := Label.new()
		var datetime := Time.get_datetime_dict_from_system()
		timeLabel.text = "[%02d:%02d:%02d]" % [datetime.hour, datetime.minute, datetime.second]
		timeLabel.name = "Time"
		timeLabel.add_theme_color_override("font_color", Color(text_color.r + info_overlay.r, text_color.g + info_overlay.g, text_color.b + info_overlay.b, info_overlay.a))
		hbox.add_child(timeLabel)
	
	if sender != "":
		var senderLabel := Label.new()
		senderLabel.name = "Sender"
		senderLabel.text = sender + ":"
		senderLabel.add_theme_color_override("font_color", Color(text_color.r + info_overlay.r, text_color.g + info_overlay.g, text_color.b + info_overlay.b, info_overlay.a))
		hbox.add_child(senderLabel)
	
	var contentLabel = Label.new()
	contentLabel.name = "Content"
	contentLabel.text = message
	contentLabel.add_theme_color_override("font_color", text_color)
	hbox.add_child(contentLabel)


func send_tower_message(message : String) -> void:
	send_message(message, "You", true, tower_text_color)
