@icon("res://Assets/Icons/NodesIcons/Cog.svg")

class_name ActionNode

extends MonologueGraphNode


@onready var option_container = $OptionMarginContainer
@onready var variable_container = $VariableMarginContainer
@onready var custom_container = $CustomMarginContainer
@onready var timer_container = $TimerMarginContainer
@onready var loop_value_container = $CustomMarginContainer/CustomContainer/LoopValueContainer

@onready var action_type_label = $ActionTypeMarginContainer/ActionTypeContainer/ActionTypeContainer/ActionTypeLabel
@onready var option_id_label = $OptionMarginContainer/OptionContainer/OptionIdContainer/OptionIdLabel
@onready var option_value_label = $OptionMarginContainer/OptionContainer/ValueContainer/ValueLabel
@onready var variable_name_label = $VariableMarginContainer/VariableContainer/VariableNameContainer/VariableNameLabel
@onready var variable_operator_label = $VariableMarginContainer/VariableContainer/OperatorContainer/OperatorLabel
@onready var variable_value_label = $VariableMarginContainer/VariableContainer/ValueContainer/ValueLabel
@onready var custom_type_label = $CustomMarginContainer/CustomContainer/CustomTypeContainer/CustomTypeLabel
@onready var custom_value_label = $CustomMarginContainer/CustomContainer/CustomValueContainer/CustomValueLabel
@onready var wait_value_label = $TimerMarginContainer/CustomContainer/TimerValueContainer/TimerValueLabel

var action_type: String = "ActionOption"
var option_id: String = ""
var variable_name: String = ""
var operator: String = ""
var custom_type: String = ""
var loop: bool = false
var volume: float = 0.0
var pitch: float = 1.0
var value = false

func _ready():
	node_type = "NodeAction"
	title = node_type

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
			if custom_type == "PlayAudio":
				loop = action.get("Loop")
				volume = action.get("Volume", 0.0)
				pitch = action.get("Pitch", 1.0)
	value = action.get("Value")
	
	_update()
	
	var _pos = dict.get("EditorPosition")
	position_offset.x = _pos.get("x")
	position_offset.x = _pos.get("y")
	

func _action_to_dict() -> Dictionary:
	if action_type == "ActionOption":
		return {
			"$type": action_type,
			"OptionID": option_id,
			"Value": value
		}
	elif action_type == "ActionCustom":
		if custom_type == "PlayAudio":
			return {
				"$type": action_type,
				"CustomType": custom_type,
				"Value": value,
				"Volume": volume,
				"Pitch": pitch,
				"Loop": loop
			}
		return {
			"$type": action_type,
			"CustomType": custom_type,
			"Value": value
		}
	elif action_type == "ActionTimer":
		return {
			"$type": action_type,
			"Value": value
		}
		
	# ActionVariable
	return {
		"$type": action_type,
		"Operator": operator,
		"Variable": variable_name,
		"Value": value
	}

func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()


func _update(panel: ActionNodePanel = null):
	if panel != null:
		action_type = panel.action_type
		value = panel.get_value()
		
		match action_type:
			"ActionOption":
				option_id = panel.option_id_edit.text
				
				if option_id != "":
					var is_option_id_valid: bool = get_parent().is_option_node_exciste(option_id)
					panel.option_not_find.visible = !is_option_id_valid
				else:
					panel.option_not_find.hide()
			"ActionVariable":
				if panel.variable_drop_node.selected >= 0:
					variable_name = panel.variable_drop_node.get_item_text(panel.variable_drop_node.selected)
				operator = panel.operator_drop_node.get_item_text(panel.operator_drop_node.selected)
			"ActionCustom":
				custom_type = panel.custom_drop_node.get_item_text(panel.custom_drop_node.selected)
				custom_value_label.text = value
				loop = panel.loop_edit.button_pressed
				volume = panel.volume_value
				pitch = panel.pitch_value
			"ActionTimer":
				pass
	
	
	action_type_label.text = action_type
	
	option_container.hide()
	variable_container.hide()
	custom_container.hide()
	timer_container.hide()
	
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
			loop_value_container.hide()
			
			match custom_type:
				"PlayAudio":
					title = "🎵 " + node_type
					loop_value_container.visible = loop
				"UpdateBackground":
					title = "🖼️ " + node_type
		"ActionTimer":
			wait_value_label.text = str(value) if value else "0"
			timer_container.show()
