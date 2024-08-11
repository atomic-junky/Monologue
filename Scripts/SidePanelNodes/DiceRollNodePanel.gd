@icon("res://Assets/Icons/NodesIcons/DiceRoll.svg")

class_name DiceRollNodePanel

extends MonologueNodePanel


@onready var target_number_node = $SubContainer/TargetNumber

var target_number: int = 0


func _ready():
	var line_edit: LineEdit = target_number_node.get_line_edit()
	line_edit.connect("focus_exited", _on_target_number_focus_exited)
	line_edit.connect("text_submitted", _on_target_number_submitted)


func _from_dict(dict):
	id = dict.get("ID")
	target_number = dict.get("Target")
	
	target_number_node.value = target_number


func _on_target_number_focus_exited():
	_on_target_number_submitted(target_number_node.value)


func _on_target_number_submitted(new_value):
	var new_number = int(new_value)
	if new_number < 0 or new_number > 100:
		target_number_node.value = target_number
		return
	
	target_number = new_number
	_on_node_property_change(["target_number"], [new_number])
	get_viewport().gui_release_focus()
