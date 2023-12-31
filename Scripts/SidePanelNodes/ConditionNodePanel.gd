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
	variables = graph_node.get_parent().variables
	
	for variable in variables:
		variable_drop_node.add_item(variable.get("Name"))

func _from_dict(dict: Dictionary):
	id = dict.get("ID")
	var condition = dict.get("Condition")
	var variables_filter = variables.filter(func(v): return v.get("Name") == condition.get("Variable"))
	
	if variables_filter.size() > 0:
		for i in variable_drop_node.item_count:
			if variable_drop_node.get_item_text(i) == condition.get("Variable"):
				variable_drop_node.select(i)
			
	
	for i in operator_drop_node.item_count:
		if operator_drop_node.get_item_text(i) == condition.get("Operator"):
			operator_drop_node.select(i)
	
	var value = condition.get("Value")
	if value != null and variables_filter.size() > 0:
		var variable = variables.filter(func(v): return v.get("Name") == condition.get("Variable"))[0]
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
	
	match variable.get("Type"):
		"Boolean":
			boolean_edit.show()
			boolean_edit.grab_focus()
		"Integer":
			number_edit.show()
			number_edit.grab_focus()
		"String":
			string_edit.show()
			string_edit.grab_focus()
		_:
			default_label.show()
			default_label.grab_focus()


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


func update(_x = null):
	update_all_condition()
	change.emit(self)
