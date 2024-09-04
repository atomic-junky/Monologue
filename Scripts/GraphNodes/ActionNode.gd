@icon("res://Assets/Icons/NodesIcons/Cog.svg")
class_name ActionNode extends MonologueGraphNode


const ACTIONS = [
	{ "id": 0, "text": "ActionOption", "metadata": MonologueValue.BOOLEAN },
	{ "id": 1, "text": "ActionVariable" },
	{ "id": 2, "text": "ActionCustom", "metadata": MonologueValue.STRING },
	{ "id": 3, "text": "ActionTimer", "metadata": MonologueValue.INTEGER },
]
const CUSTOMS = [
	{ "id": 0, "text": "PlayAudio", "metadata": MonologueValue.FILE },
	{ "id": 1, "text": "UpdateBackground", "metadata": MonologueValue.FILE },
	{ "id": 2, "text": "Other", "metadata": MonologueValue.STRING },
]

var action_type: String = "ActionOption"
var option_id: String = ""
var variable: String = ""
var operator: String = ""
var custom_type: String = ""
var loop: bool = false
var volume: float = 0.0
var pitch: float = 1.0
var value: Variant = false

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


func _ready():
	node_type = "NodeAction"
	title = node_type


func get_fields() -> Array[MonologueField]:
	# Group 0: ActionOption
	var option_id_field = MonologueLineEdit.new("option_id",
			"Option", option_id).label("Option ID").build()
	
	# Group 1: ActionVariable
	var variable_field = MonologueOptionButton.new("variable",
			"Variable", variable).label("Variable").build() \
			.set_items(get_parent().variables, "Name", "ID", "Type")
	var operator_field = MonologueOperator.new("operator",
			"Operator", MonologueOperator.MATHS).build()
	
	# Group 2: ActionCustom
	var custom_field = MonologueAccordion.new("custom_type",
			"CustomType", custom_type).label("Type").build() \
			.group(0, _get_audio_fields()) \
			.group(1, []) \
			.group(2, []) \
			.set_items(CUSTOMS)
	
	# Always-Displayed Fields
	var action_field = MonologueAccordion.new("action_type",
			"Action", action_type).label("Action Type").build() \
			.group(0, [option_id_field]) \
			.group(1, [variable_field, operator_field]) \
			.group(2, [custom_field]) \
			.group(3, []) \
			.set_items(ACTIONS)
	var value_field = MonologueValue.new(value).vary(variable_field) \
			.vary(custom_field).vary(action_field).build()
	
	return [action_field, value_field]


func _get_audio_fields():
	return [
		MonologueCheckButton.new("loop", "Loop", loop).label("Loop?").build(),
		MonologueSlider.new("volume", "Volume", volume).label("Volume")
				.suffix("db").build().limit(-80, 24, 0.25),
		MonologueSlider.new("pitch", "Pitch", pitch).label("Pitch")
				.build().limit(0, 4, 0.1).default(1),
	]


func _update(_panel: ActionNodePanel = null):
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
			variable_name_label.text = variable if variable else "variable"
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
