extends PanelContainer


@onready var ref_input = $MarginContainer/HBoxContainer2/LineEdit

var id = -1
var update_callback: Callable = GlobalVariables.empty_callback
var character_name : set = set_character_name, get = get_character_name


func _to_dict():
	return {
		"Reference": character_name,
		"ID": id
	}


func _from_dict(dict):
	character_name = dict.get("Reference")
	id = dict.get("ID")


func set_character_name(new_name):
	character_name = new_name
	ref_input.text = new_name


func get_character_name():
	return character_name


func _on_delete_pressed():
	queue_free()
	update_callback.call()


func _on_line_edit_focus_exited():
	_on_line_edit_text_submitted(ref_input.text)


func _on_line_edit_text_submitted(new_text):
	if character_name != new_text:
		character_name = new_text
		update_callback.call()
