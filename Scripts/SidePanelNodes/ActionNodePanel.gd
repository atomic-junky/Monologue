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

var variables: Array
var action_type

var volume_value: float = 0.0
var pitch_value: float = 1.0

func _ready():
	variables = graph_node.get_parent().variables
	
	for variable in variables:
		variable_drop_node.add_item(variable.get("Name"))

func _from_dict(dict: Dictionary):
	variables = graph_node.get_parent().variables
	
	id = dict.get("ID")
	
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
	var exceptions = []
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
			var variable_name = variable_drop_node.get_item_text(variable_drop_node.selected)
			if not variable_name:
				return
			var variable = variables.filter(func (v): return v.get("Name") == variable_name)[0]
			
			var is_integer: bool = variable.get("Type") == "Integer"
			operator_drop_node.set_item_disabled(1, !is_integer)
			operator_drop_node.set_item_disabled(2, !is_integer)
			operator_drop_node.set_item_disabled(3, !is_integer)
			operator_drop_node.set_item_disabled(4, !is_integer)
			
			match variable.get("Type"):
				"Boolean":
					hide_all([boolean_edit, variable_container, operator_container])
				"Integer":
					hide_all([number_edit, variable_container, operator_container])
				"String":
					hide_all([string_edit, variable_container, operator_container])
				_:
					hide_all([default_label, variable_container, operator_container])
		"ActionCustom":
			hide_all([custom_container, string_edit])
			if custom_drop_node.selected <= -1:
				custom_drop_node.selected = 2
			var custom_type = custom_drop_node.get_item_text(custom_drop_node.selected)
			if custom_type == "PlayAudio":
				audio_loop_container.show()
				audio_extra_container.show()
				_update_slider_value(volume_value, pitch_value)
		"ActionTimer":
			hide_all([number_edit])
	
	$ActionTypeContainer.show()
	$ValueContainer/ValueLabel.show()
	
	change.emit(self)


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


func _on_action_type_drop_item_selected(_index):
	update_action()

func _on_variable_drop_item_selected(_index):
	update_action()


func _update_slider_value(volume = null, pitch = null):
	volume_value = snapped(%VolumeSlider.value, 0.01) if not volume else volume
	pitch_value = %PitchSlider.value if not pitch else pitch
	
	%VolumeDisplay.text = str(volume_value) + "db"
	%PitchDisplay.text = str(pitch_value)

func _on_pitch_reset_pressed():
	%PitchSlider.value = 1

func _on_volume_reset_pressed():
	%VolumeSlider.value = 0
