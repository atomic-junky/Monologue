@icon("res://Assets/Icons/NodesIcons/DiceRoll.svg")

class_name DiceRollNodePanel

extends MonologueNodePanel


@onready var target_number_node = $SubContainer/TargetNumber

var target_number: int = 0


func _from_dict(dict):
	id = dict.get("ID")
	target_number = dict.get("Target")
	
	target_number_node.value = target_number


func _on_target_number_value_changed(value):
	if value < 0 or value > 100:
		target_number_node.value = target_number
		return
	target_number = value
	
	change.emit(self)
