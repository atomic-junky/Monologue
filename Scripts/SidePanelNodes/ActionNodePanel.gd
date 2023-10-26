@icon("res://Assets/Icons/NodesIcons/Cog.svg")

class_name ActionNodePanel

extends VBoxContainer


@onready var option_id_container = $OptionIDContainer
@onready var variable_container = $VariableContainer
@onready var operator_container = $OperatorContainer
@onready var custom_container = $CustomContainer

@onready var action_drop_node: OptionButton = $ActionTypeContainer/ActionTypeDrop
@onready var option_id_edit: LineEdit = $OptionIDContainer/VBoxContainer/OptionIDEdit
@onready var option_not_find = $OptionIDContainer/VBoxContainer/OptionNotFindLabel
@onready var variable_drop_node: OptionButton = $VariableContainer/VariableDrop
@onready var operator_drop_node: OptionButton = $OperatorContainer/OperatorDrop
@onready var custom_drop_node: OptionButton = $CustomContainer/CustomDrop

@onready var boolean_edit: CheckButton = $ValueContainer/BooleanEdit
@onready var number_edit: SpinBox = $ValueContainer/NumberEdit
@onready var string_edit: LineEdit = $ValueContainer/StringEdit
@onready var default_label: Label = $ValueContainer/DefaultLabel

var graph_node

var id = UUID.v4()
var variables: Array

func _ready():
	variables = graph_node.get_parent().variables
	
	for variable in variables:
		variable_drop_node.add_item(variable.get("Name"))

func _from_dict(dict: Dictionary):
	id = dict.get("ID")
	var action = dict.get("Action")
	variables = graph_node.get_parent().variables
	
	match action.get("$type"):
		"ActionOption":
			action_drop_node.select(0)
			option_id_edit.text = action.get("OptionID", "")
			boolean_edit.button_pressed = action.get("Value", false)
		"ActionVariable":
			action_drop_node.select(1)
			
			var variables_filter = variables.filter(func(v): return v.get("Name") == action.get("Variable"))
			
			if variables_filter.size() > 0:
				var variable = variables_filter[0]
				var variable_position = variables.find(variable)
				variable_drop_node.select(variable_position)
				
				var value = action.get("Value")
				match variable.get("Type"):
					"Boolean":
						boolean_edit.button_pressed = value
					"Integer":
						number_edit.value = value
					"String":
						string_edit.text = value
		"ActionCustom":
			action_drop_node.select(2)
			match action.get("CustomType"):
				"PlayMusic":
					custom_drop_node.select(0)
				"UpdateBackground":
					custom_drop_node.select(1)
				"Other":
					custom_drop_node.select(2)
					
			string_edit.text = action.get("Value", "")
	
	update_action()


func update_action():
	var action_type = action_drop_node.get_item_text(action_drop_node.selected)
	
	option_id_container.hide()
	variable_container.hide()
	operator_container.hide()
	custom_container.hide()
	
	match action_type:
		"ActionOption":
			option_id_container.show()
			boolean_edit.show()
			number_edit.hide()
			string_edit.hide()
			default_label.hide()
		"ActionVariable":
			variable_container.show()
			operator_container.show()
			
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
			operator_drop_node.set_item_disabled(3, !is_integer)
			operator_drop_node.set_item_disabled(4, !is_integer)
			
			match variable.get("Type"):
				"Boolean":
					boolean_edit.show()
				"Integer":
					number_edit.show()
				"String":
					string_edit.show()
				_:
					default_label.show()
		"ActionCustom":
			option_id_container.hide()
			boolean_edit.hide()
			number_edit.hide()
			default_label.hide()
			
			custom_container.show()
			string_edit.show()

func update_graph_node(_value = null):
	update_action()
	var action_type = action_drop_node.get_item_text(action_drop_node.selected)
	graph_node.action_type = action_type
	graph_node.value = get_value()
	
	match action_type:
		"ActionOption":
			graph_node.option_id = option_id_edit.text
			
			var option_id = option_id_edit.text
			if option_id != "":
				var is_option_id_valid: bool = graph_node.get_parent().is_option_node_exciste(option_id)
				option_not_find.visible = !is_option_id_valid
			else:
				option_not_find.hide()
		"ActionVariable":
			if variable_drop_node.selected >= 0:
				graph_node.variable_name = variable_drop_node.get_item_text(variable_drop_node.selected)
			graph_node.operator = operator_drop_node.get_item_text(operator_drop_node.selected)
		"ActionCustom":
			graph_node.custom_type = custom_drop_node.get_item_text(custom_drop_node.selected)
			graph_node.custom_value_label.text = get_value()
	
	graph_node.update_preview()


func get_value():
	var action_type = action_drop_node.get_item_text(action_drop_node.selected)
	match action_type:
		"ActionOption":
			return boolean_edit.button_pressed
		"ActionCustom":
			return string_edit.text
		"ActionVariable":
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


func _on_action_type_drop_item_selected(_index):
	update_action()
	update_graph_node()


func _on_variable_drop_item_selected(_index):
	update_action()
	update_graph_node()


func _on_operator_drop_item_selected(_index):
	update_graph_node()
