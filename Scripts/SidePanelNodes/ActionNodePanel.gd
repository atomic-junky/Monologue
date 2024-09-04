@icon("res://Assets/Icons/NodesIcons/Cog.svg")

class_name ActionNodePanel
extends MonologueNodePanel


@onready var option_id_container = $OptionIDContainer
@onready var variable_container = $VariableContainer
@onready var operator_container = $OperatorContainer
@onready var custom_container = $CustomContainer
@onready var audio_loop_container = $AudioLoopContainer
@onready var audio_extra_container = $AudioExtraContainer

@onready var action_drop_node: OptionButton = $ActionTypeContainer/ActionTypeDrop
@onready var option_id_edit: LineEdit = $OptionIDContainer/VBoxContainer/OptionIDEdit
@onready var option_not_find = $OptionIDContainer/VBoxContainer/OptionNotFindLabel
@onready var variable_drop_node: OptionButton = $VariableContainer/VariableDrop
@onready var operator_drop_node: OptionButton = $OperatorContainer/OperatorDrop
@onready var custom_drop_node: OptionButton = $CustomContainer/CustomDrop
@onready var loop_edit: CheckButton = $AudioLoopContainer/BooleanEdit

@onready var boolean_edit: CheckButton = $ValueContainer/BooleanEdit
@onready var number_edit: SpinBox = $ValueContainer/NumberEdit
@onready var string_edit: LineEdit = $ValueContainer/StringEdit
@onready var default_label: Label = $ValueContainer/DefaultLabel

var action_type

var variables = []
var volume_value: float = 0.0
var pitch_value: float = 1.0


func _ready():
	for variable in variables:
		variable_drop_node.add_item(variable.get("Name"))
	
	var inner_edit: LineEdit = number_edit.get_line_edit()
	inner_edit.connect("focus_exited", _on_individual_value_changed)
	inner_edit.connect("text_submitted", _on_individual_value_changed)


func _from_dict(dict: Dictionary):
	var action = dict.get("Action")
	action_type =  action.get("$type")
	
	match action_type:
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
			
			var operator_str: String = action.get("Operator")
			var operator_id := 0
			for op in operator_drop_node.item_count:
				if operator_drop_node.get_item_text(op) == operator_str:
					operator_id = op
			operator_drop_node.select(operator_id)
		
		"ActionCustom":
			action_drop_node.select(2)
			
			match action.get("CustomType"):
				"PlayAudio":
					custom_drop_node.select(0)
					loop_edit.button_pressed = action.get("Loop")
					volume_value = action.get("Volume")
					pitch_value = action.get("Pitch")
				"PlayMusic": # Compatibilty with version 2.0.0
					custom_drop_node.select(0)
				"UpdateBackground":
					custom_drop_node.select(1)
				"Other":
					custom_drop_node.select(2)
			
			string_edit.text = action.get("Value", "")
		
		"ActionTimer":
			action_drop_node.select(3)
			number_edit.value = action.get("Value", 0.0)
	
	update_action()


func hide_all(except_nodes: Array):
	# for this panel, action_type and value label is always shown
	var exceptions = ["ActionTypeContainer", "ValueLabel"]
	for node in except_nodes:
		exceptions.append(node.name)
	
	for child in get_children():
		if child.name in exceptions:
			child.show()
			continue
			
		if child == $ValueContainer:
			for subchild in $ValueContainer.get_children():
				subchild.visible = subchild.name in exceptions
			continue
			
		child.hide()


func update_action(_x = null):
	action_type = action_drop_node.get_item_text(action_drop_node.selected)
	
	match action_type:
		"ActionOption":
			hide_all([option_id_container, boolean_edit])
		
		"ActionVariable":
			update_variable()
		
		"ActionCustom":
			update_custom(custom_drop_node.selected, false)
		
		"ActionTimer":
			hide_all([number_edit])
	
	var value = get_value()
	if value != null:
		_on_node_property_change(["action_type", "value"], [action_type, value])


func update_custom(custom_index, record = true):
	hide_all([custom_container, string_edit])
	
	if custom_drop_node.selected >= 0:
		var custom_type = custom_drop_node.get_item_text(custom_index)
		if custom_type == "PlayAudio":
			audio_loop_container.show()
			audio_extra_container.show()
			%VolumeSlider.value = volume_value
			_update_volume_display_value(volume_value)
			%PitchSlider.value = pitch_value
			_update_pitch_display_value(pitch_value)
		
		if record:
			_on_node_property_change(["custom_type"], [custom_type])
	else:
		custom_drop_node.selected = 2


func update_variable(variable_index = -1):
	var variable_name = ""
	var variable_type = ""
	if variable_drop_node.has_selectable_items():
		variable_name = variable_drop_node.get_item_text(variable_drop_node.selected)
		var variable = variables.filter(func (v): return v.get("Name") == variable_name)[0]
		variable_type = variable.get("Type")
	
	var is_integer: bool = variable_type == "Integer"
	var blocked_index = [1, 2, 3, 4]  # items blocked if is_integer == false
	for index in blocked_index:
		operator_drop_node.set_item_disabled(index, !is_integer)
	
	# reset if invalid operator is selected for the updated variable type
	if !is_integer and blocked_index.has(operator_drop_node.selected):
		operator_drop_node.selected = 0
	
	match variable_type:
		"Boolean":
			hide_all([boolean_edit, variable_container, operator_container])
		"Integer":
			hide_all([number_edit, variable_container, operator_container])
		"String":
			hide_all([string_edit, variable_container, operator_container])
		_:
			hide_all([default_label, variable_container, operator_container])
	
	if variable_index >= 0 and variable_name:
		var operator = operator_drop_node.get_item_text(operator_drop_node.selected)
		var value = get_value()
		
		if value != null:
			var properties = ["variable_name", "operator", "value"]
			var values = [variable_name, operator, value]
			_on_node_property_change(properties, values)


func get_value():
	action_type = action_drop_node.get_item_text(action_drop_node.selected)
	
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
		
		"ActionTimer":
			return number_edit.value


func _on_individual_value_changed(_new_value = null):
	var value = get_value()
	if value != null:
		_on_node_property_change(["value"], [value])


func _on_operator_selected(index):
	var operator = operator_drop_node.get_item_text(index)
	_on_node_property_change(["operator"], [operator])

func _on_option_id_focus_exited():
	_on_option_id_text_submitted(option_id_edit.text)

func _on_option_id_text_submitted(new_text):
	_on_node_property_change(["option_id"], [new_text])


# audio controls
func _on_loop_toggled(toggled_on: bool):
	_on_node_property_change(["loop"], [toggled_on])

func _on_pitch_reset_pressed():
	%PitchSlider.value = 1
	_on_pitch_slider_release()

func _on_pitch_slider_release(_value_on_release = 1.0):
	_on_node_property_change(["pitch"], [pitch_value])

func _on_volume_reset_pressed():
	%VolumeSlider.value = 0
	_on_volume_slider_release()

func _on_volume_slider_release(_value_on_release = 0.0):
	_on_node_property_change(["volume"], [volume_value])

func _update_pitch_display_value(new_pitch):
	pitch_value = new_pitch
	%PitchDisplay.text = str(new_pitch)

func _update_volume_display_value(new_volume):
	volume_value = new_volume
	%VolumeDisplay.text = str(new_volume) + "db"
