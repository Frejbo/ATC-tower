extends VBoxContainer
class_name Chat

@export var tower_text_color : Color
@export var aircraft_text_color : Color
@export var info_overlay : Color = Color(0, 0, 0, .75)

var voice_id = DisplayServer.tts_get_voices_for_language("en")[0]

const callsign_telephony_designators : Dictionary = {
	"SAS":"Scandinavian",
}
const phonetic_alphabet : Dictionary = {
	"A":"Alpha",
	"B":"Bravo",
	"C":"Charlie",
	"D":"Delta",
	"E":"Echo",
	"F":"Foxtrot",
	"G":"Golf",
	"H":"Hotel",
	"I":"India",
	"J":"Juliett",
	"K":"Kilo",
	"L":"Lima",
	"M":"Mike",
	"N":"November",
	"O":"Oscar",
	"P":"Papa",
	"Q":"Quebec",
	"R":"Romeo",
	"S":"Sierra",
	"T":"Tango",
	"U":"Uniform",
	"V":"Victor",
	"W":"Whiskey",
	"X":"X-ray",
	"Y":"Yankee",
	"Z":"Zulu"
}

func _enter_tree() -> void:
	Game.chat = self
	

func send_message(message : String, sender : String = "", include_time : bool = true, text_color : Color = aircraft_text_color) -> void:
	DisplayServer.tts_speak(format_tts(message), voice_id)
	
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


func format_tts(message : String) -> String:
	# Replace 3-digit callsign with telephony designators
	for key : String in callsign_telephony_designators.keys():
		message = message.replace(key, callsign_telephony_designators.get(key))
	
	var formatted_msg := ""
	var i := 0
	for c : String in message:
		if c == c.to_upper():
			# Character is uppercase
			
			if message.length()-1 == i or message[i+1] == message[i+1].to_upper():
				# This is the last character in message, OR next character is uppercase.
				# Should therefore be phoneticly pronounced.
				if phonetic_alphabet.has(c):
					formatted_msg += " "
					c = phonetic_alphabet.get(c)
	
	# Separate all the numbers to be spoken separately.
		if c.is_valid_int():
			if not formatted_msg.ends_with(" "):
				formatted_msg += " "
		formatted_msg += c
		i += 1
	
	# Remove extra blank spaces
	while "  " in formatted_msg:
		formatted_msg = formatted_msg.replace("  ", " ")
	
	return formatted_msg

func send_tower_message(message : String) -> void:
	send_message(message, "You", true, tower_text_color)
