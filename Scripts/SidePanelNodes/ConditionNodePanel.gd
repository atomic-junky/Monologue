@icon("res://Assets/Icons/NodesIcons/Condition.svg")

class_name ConditionNodePanel
extends MonologueNodePanel


@onready var variable_drop_node: OptionButton = $IfContainer/VariableDrop
@onready var operator_drop_node: OptionButton = $OperatorContainer/OperatorDrop

@onready var boolean_edit: CheckButton = $ValueContainer/BooleanEdit
@onready var number_edit: SpinBox = $ValueContainer/NumberEdit
@onready var string_edit: LineEdit = $ValueContainer/StringEdit
@onready var default_label: Label = $ValueContainer/DefaultLabel

var variables: Array


func _ready():
	variable_drop_node.clear()
	variables = graph_node.get_parent().variables
	
	for variable in variables:
		variable_drop_node.add_item(variable.get("Name"))
	
	var inner_edit: LineEdit = number_edit.get_line_edit()
	inner_edit.connect("focus_exited", _on_value_changed)
	inner_edit.connect("text_submitted", _on_value_changed)


func _from_dict(dict: Dictionary):
	id = dict.get("ID")
	var condition = dict.get("Condition")
	var variable_name = condition.get("Variable")
	var variables_filter = variables.filter(func(v): return v.get("Name") == variable_name)
	
	# select variable dropdown by its name
	if variables_filter.size() > 0:
		for i in variable_drop_node.item_count:
			if variable_drop_node.get_item_text(i) == variable_name:
				variable_drop_node.select(i)
				break
	
	# select operator dropdown
	for i in operator_drop_node.item_count:
		if operator_drop_node.get_item_text(i) == condition.get("Operator"):
			operator_drop_node.select(i)
			break
	
	# load the variable's value
	var value = condition.get("Value")
	if value != null and variables_filter.size() > 0:
		var variable = variables.filter(func(v): return v.get("Name") == variable_name)[0]
		match variable.get("Type"):
			"Boolean":
				boolean_edit.button_pressed = value
			"Integer":
				number_edit.value = value
			"String":
				string_edit.text = value
	
	update_all_condition()


func update_all_condition():
	if variable_drop_node.selected <= -1:
		return
	
	var variable_name = variable_drop_node.get_item_text(variable_drop_node.selected)
	if not variable_name:
		return
	
	var variable = variables.filter(func (v): return v.get("Name") == variable_name)[0]
	
	boolean_edit.hide()
	number_edit.hide()
	string_edit.hide()
	default_label.hide()
	
	var is_integer: bool = variable.get("Type") == "Integer"
	operator_drop_node.set_item_disabled(1, !is_integer)
	operator_drop_node.set_item_disabled(2, !is_integer)
	
	# may need to reset operator selection due to variable type change
	if !is_integer and (operator_drop_node.selected == 1 or operator_drop_node.selected == 2):
		operator_drop_node.selected = 0
	
	match variable.get("Type"):
		"Boolean":
			boolean_edit.show()
		"Integer":
			number_edit.show()
		"String":
			string_edit.show()
		_:
			default_label.show()


func get_value():
	if variable_drop_node.selected < 0:
		return null
	
	var variable_name = variable_drop_node.get_item_text(variable_drop_node.selected)
	if not variable_name:
		return null
	
	var variable = variables.filter(func (v): return v.get("Name") == variable_name)[0]
	
	match variable.get("Type"):
		"Boolean":
			return boolean_edit.button_pressed
		"Integer":
			return number_edit.value
		"String":
			return string_edit.text
		_:
			return null


func _on_variable_selected(index):
	update_all_condition()
	
	var variable_name = variable_drop_node.get_item_text(index)
	var operator = operator_drop_node.get_item_text(operator_drop_node.selected)
	var value = get_value()
	
	if value != null:
		var properties = ["variable_name", "operator", "value"]
		var values = [variable_name, operator, value]
		_on_node_property_changes(properties, values)


func _on_operator_selected(index):
	var operator = operator_drop_node.get_item_text(index)
	_on_node_property_changes(["operator"], [operator])


func _on_value_changed(_new_value = null):
	# important to do null checks here due to falsy values
	var value = get_value()
	if value != null:
		_on_node_property_changes(["value"], [value])
