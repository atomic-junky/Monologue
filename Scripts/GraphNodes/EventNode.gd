@icon("res://Assets/Icons/NodesIcons/Event.svg")
class_name EventNode extends VariableNode


func _ready():
	node_type = "NodeEvent"
	super._ready()
	variable.callers["set_label_text"] = ["When"]


func get_variable_label() -> Label:
	return $MarginWhenContainer/WhenContainer/VariableLabel


func get_operator_label() -> Label:
	return $MarginWhenContainer/WhenContainer/OperatorLabel


func get_value_label() -> Label:
	return $MarginWhenContainer/WhenContainer/ValueLabel


func get_operator_options():
	return [
		{ "id": 0, "text": "=="  },
		{ "id": 1, "text": ">=" },
		{ "id": 2, "text": "<=" },
		{ "id": 3, "text": "!=" },
	]


func get_operator_disabler():
	return [1, 2]


func _from_dict(dict: Dictionary):
	var condition = dict.get("Condition")
	for v in get_graph_edit().variables:
		if v.get("Name") == condition.get("Variable"):
			variable.value = condition.get("Variable")
			break
	
	operator.value = condition.get("Operator", "==")
	value.value = condition.get("Value", "")
	super._from_dict(dict)
