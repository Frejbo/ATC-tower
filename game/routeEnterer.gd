@tool
extends LineEdit


func _on_text_changed(new_text: String) -> void:
	var regex = RegEx.new()
	regex.compile("[A-Z1-9,]")
	
	var caret_pos = caret_column
	
	new_text = new_text.replace(", ", ",")
	new_text = new_text.replace(" ", ",")
	while ",," in new_text:
		new_text = new_text.replace(",,", ",")
	
	var t := ""
	for character in new_text.to_upper():
		if not regex.search(character): continue
		t += character
	text = t
	caret_column = caret_pos

func get_route() -> Array[String]:
	var regex = RegEx.new()
	regex.compile("[A-Z1-9]")
	var route : Array[String] = []
	for character in text:
		if not regex.search(character): continue
		route.append(character)
	print("Route: ", route)
	return route
