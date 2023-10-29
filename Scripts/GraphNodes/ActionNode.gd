@icon("res://Assets/Icons/NodesIcons/Cog.svg")

class_name ActionNode

extends GraphNode


@onready var option_container = $OptionMarginContainer
@onready var variable_container = $VariableMarginContainer
@onready var custom_container = $CustomMarginContainer

@onready var action_type_label = $ActionTypeMarginContainer/ActionTypeContainer/ActionTypeContainer/ActionTypeLabel
@onready var option_id_label = $OptionMarginContainer/OptionContainer/OptionIdContainer/OptionIdLabel
@onready var option_value_label = $OptionMarginContainer/OptionContainer/ValueContainer/ValueLabel
@onready var variable_name_label = $VariableMarginContainer/VariableContainer/VariableNameContainer/VariableNameLabel
@onready var variable_operator_label = $VariableMarginContainer/VariableContainer/OperatorContainer/OperatorLabel
@onready var variable_value_label = $VariableMarginContainer/VariableContainer/ValueContainer/ValueLabel
@onready var custom_type_label = $CustomMarginContainer/CustomContainer/CustomTypeContainer/CustomTypeLabel
@onready var custom_value_label = $CustomMarginContainer/CustomContainer/CustomValueContainer/CustomValueLabel

var id = UUID.v4()
var node_type = "NodeAction"

var action_type: String = "ActionOption"
var option_id: String = ""
var variable_name: String = ""
var operator: String = ""
var custom_type: String = ""
var value = false

func _ready():
	update_preview()

func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_id_node[0].id if next_id_node else -1,
		"Action": _action_to_dict(),
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict: Dictionary):
	id = dict.get("ID")
	
	var action: Dictionary = dict.get("Action")
	
	action_type = action.get("$type")
	match action_type:
		"ActionOption":
			option_id = action.get("OptionID")
		"ActionVariable":
			operator = action.get("Operator")
			variable_name = action.get("Variable")
		"ActionCustom":
			custom_type = action.get("CustomType", "")
	value = action.get("Value")
	
	var _pos = dict.get("EditorPosition")
	position_offset.x = _pos.get("x")
	position_offset.x = _pos.get("y")
	
	update_preview()


func _action_to_dict() -> Dictionary:
	if action_type == "ActionOption":
		return {
			"$type": action_type,
			"OptionID": option_id,
			"Value": value
		}
	elif action_type == "ActionCustom":
		return {
			"$type": action_type,
			"CustomType": custom_type,
			"Value": value
		}
		
	# ActionVariable
	return {
		"$type": action_type,
		"Operator": operator,
		"Variable": variable_name,
		"Value": value
	}


func update_preview():
	title = node_type
	
	action_type_label.text = action_type
	
	option_container.hide()
	variable_container.hide()
	custom_container.hide()
	
	match action_type:
		"ActionOption":
			option_id_label.text = option_id.split("-")[0] if option_id else "option id"
			option_value_label.text = str(value) if value != null else "value"
			option_container.show()
		"ActionVariable":
			variable_name_label.text = variable_name if variable_name else "variable"
			variable_operator_label.text = operator if operator else "operator"
			variable_value_label.text = str(value) if value != null else "value"
			variable_container.show()
		"ActionCustom":
			custom_type_label.text = custom_type if custom_type else "custom type"
			custom_value_label.text = str(value) if value else "nothing"
			custom_container.show()
			
			match custom_type:
				"PlayAudio":
					title = "🎵 " + node_type
				"UpdateBackground":
					title = "🖼️ " + node_type
					


func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()
