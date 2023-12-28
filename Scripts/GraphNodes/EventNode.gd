@icon("res://Assets/Icons/NodesIcons/Event.svg")

class_name EventNode

extends MonologueGraphNode


@onready var variable_label = $MarginWhenContainer/WhenContainer/VariableLabel
@onready var operator_label = $MarginWhenContainer/WhenContainer/OperatorLabel
@onready var value_label = $MarginWhenContainer/WhenContainer/ValueLabel

var variable_name: String = ""
var operator: String = ""
var value = null

func _ready():
	node_type = "NodeEvent"
	title = node_type

func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_id_node[0].id if next_id_node else -1,
		"Condition": _condtion_to_dict(),
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict: Dictionary):
	id = dict.get("ID")
	
	var condition = dict.get("Condition")
	var variables_filter = get_parent().variables.filter(func(v): return v.get("Name") == condition.get("Variable"))
	if variables_filter.size() > 0:
		variable_name = condition.get("Variable")
	else:
		variable_name = "variable"
	operator = condition.get("Operator")
	value = condition.get("Value")
	
	var _pos = dict.get("EditorPosition")
	position_offset.x = _pos.get("x")
	position_offset.x = _pos.get("y")
	
	_update()


func _condtion_to_dict() -> Dictionary:
	return {
		"Variable": variable_name,
		"Operator": operator,
		"Value": value
	}


func _update(panel: ConditionNodePanel = null):
	if panel != null:
		if panel.variable_drop_node.selected >= 0:
			variable_name = panel.variable_drop_node.get_item_text(panel.variable_drop_node.selected)
		operator = panel.operator_drop_node.get_item_text(panel.operator_drop_node.selected)
		value = panel.get_value()
		
	variable_label.text = variable_name
	operator_label.text = operator
	value_label.text = str(value)
