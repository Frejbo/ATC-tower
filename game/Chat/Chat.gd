extends VBoxContainer
class_name Chat

func _enter_tree() -> void:
	Game.chat = self

func send_message(message : String, sender : String = "", include_time : bool = true) -> void:
	var hbox := HBoxContainer.new()
	hbox.name = "message"
	add_child(hbox)
	
	if include_time:
		var timeLabel := Label.new()
		var datetime := Time.get_datetime_dict_from_system()
		timeLabel.text = "[%02d:%02d:%02d]" % [datetime.hour, datetime.minute, datetime.second]
		timeLabel.name = "Time"
		hbox.add_child(timeLabel)
	
	if sender != "":
		var senderLabel := Label.new()
		senderLabel.name = "Sender"
		senderLabel.text = sender + ":"
		hbox.add_child(senderLabel)
	
	var contentLabel = Label.new()
	contentLabel.name = "Content"
	contentLabel.text = message
	hbox.add_child(contentLabel)
