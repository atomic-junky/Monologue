@icon("res://Assets/Icons/NodesIcons/DiceRoll.svg")

class_name DiceRollNode

extends MonologueGraphNode


@onready var pass_value = $PassContainer/PassValue
@onready var fail_value = $FailContainer/FailValue

var target_number = 0


func _ready():
	node_type = "NodeDiceRoll"
	title = node_type


func _to_dict() -> Dictionary:
	var pass_id_node = get_parent().get_all_connections_from_slot(name, 0)
	var fail_id_node = get_parent().get_all_connections_from_slot(name, 1)
	
	return {
		"$type": node_type,
		"ID": id,
		"Skill": "",
		"Target": target_number,
		"PassID": pass_id_node[0].id if pass_id_node else -1,
		"FailID": fail_id_node[0].id if fail_id_node else -1,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict):
	id = dict.get("ID")
	target_number = dict.get("Target")
	_update()
	
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")


func _update(panel: DiceRollNodePanel = null):
	if panel != null:
		target_number = panel.target_number
	
	pass_value.text = "(" + str(target_number) + "%)"
	fail_value.text = "(" + str(100 - target_number) + "%)"
