@icon("res://Assets/Icons/NodesIcons/Condition.svg")

class_name ConditionNode

extends MonologueGraphNode


@onready var variable_label = $MarginIfContainer/IfContainer/VariableLabel
@onready var operator_label = $MarginIfContainer/IfContainer/OperatorLabel
@onready var value_label = $MarginIfContainer/IfContainer/ValueLabel

var variable_name: String = ""
var operator: String = ""
var value = null

func _ready():
	node_type = "NodeCondition"
	title = node_type

func _to_dict() -> Dictionary:
	var if_next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	var else_next_id_node = get_parent().get_all_connections_from_slot(name, 1)
	
	return {
		"$type": node_type,
		"ID": id,
		"IfNextID": if_next_id_node[0].id if if_next_id_node else -1,
		"ElseNextID": else_next_id_node[0].id if else_next_id_node else -1,
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


func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()
