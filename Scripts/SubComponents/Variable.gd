extends PanelContainer


@onready var type_selection = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var name_input = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

@onready var boolean_edit = $MarginContainer/VBoxContainer/HBoxContainer3/BooleanEdit
@onready var number_edit = $MarginContainer/VBoxContainer/HBoxContainer3/NumberEdit
@onready var string_edit = $MarginContainer/VBoxContainer/HBoxContainer3/StringEdit

var update_callback: Callable = GlobalVariables.empty_callback
var current_name: String:
	get:
		return current_name
	set(value):
		current_name = value
		name_input.text = value

var current_text: String:
	get:
		return current_text
	set(value):
		current_text = value
		string_edit.text = value

var current_type_index: int:
	get:
		return current_type_index
	set(index):
		current_type_index = index
		type_selection.selected = index
		update_value_edit()


func _ready():
	update_value_edit()


func _to_dict():
	return {
		"Name": name_input.text,
		"Value": get_input_value(),
		"Type": type_selection.get_item_text(type_selection.selected),
	}


func _from_dict(dict):
	current_name = dict.get("Name")
	
	var value = dict.get("Value")
	var type_name = dict.get("Type")
	match type_name:
		"Boolean":
			current_type_index = 0
			boolean_edit.button_pressed = value
		"Integer":
			current_type_index = 1
			number_edit.value = value
		"String":
			current_type_index = 2
			current_text = value


func update_value_edit():
	boolean_edit.hide()
	number_edit.hide()
	string_edit.hide()
	
	match type_selection.selected:
		0: # Boolean
			boolean_edit.show()
		1: # Integer
			number_edit.show()
		2: # String
			string_edit.show()


func get_input_value():
	match current_type_index:
		0: # Boolean
			return boolean_edit.button_pressed
		1: # Integer
			return number_edit.value
		2: # String
			return string_edit.text


func set_input_value(new_value):
	match current_type_index:
		0: # Boolean
			boolean_edit.button_pressed = new_value
		1: # Integer
			number_edit.value = new_value
		2: # String
			current_text = new_value


func _on_delete_pressed():
	queue_free()
	update_callback.call()


func _on_option_button_item_selected(new_index):
	if current_type_index != new_index:
		current_type_index = new_index
		update_value_edit()
		update_callback.call()


func value_change(_new_value):
	update_callback.call()


func _on_string_edit_focus_exited():
	_on_string_text_submitted(string_edit.text)


func _on_string_text_submitted(new_text):
	if current_text != new_text:
		current_text = new_text
		update_callback.call()


func _on_name_edit_focus_exited():
	_on_name_text_submitted(name_input.text)


func _on_name_text_submitted(new_name):
	if current_name != new_name:
		current_name = new_name
		update_callback.call()
