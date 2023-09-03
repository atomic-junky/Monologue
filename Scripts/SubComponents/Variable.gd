extends PanelContainer


@onready var type_selection = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var name_input = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

@onready var boolean_edit = $MarginContainer/VBoxContainer/HBoxContainer3/BooleanEdit
@onready var number_edit = $MarginContainer/VBoxContainer/HBoxContainer3/NumberEdit
@onready var string_edit = $MarginContainer/VBoxContainer/HBoxContainer3/StringEdit

var update_callback: Callable


func _ready():
	update_value_edit()

func _to_dict():
	return {
		"Name": name_input.text,
		"Value": get_input_value(),
		"Type": type_selection.get_item_text(type_selection.selected),
	}


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

func _on_delete_pressed():
	queue_free()
	update_callback.call()


func _on_option_button_item_selected(_index):
	update_value_edit()
	update_callback.call()


func get_input_value():
	var index = type_selection.selected
	
	match index:
		0: # Boolean
			return boolean_edit.button_pressed
		1: # Integer
			return number_edit.value
		2: # String
			return string_edit.text


func _on_line_edit_text_changed(_new_text):
	update_callback.call()

func value_change(_new_value):
	update_callback.call()
