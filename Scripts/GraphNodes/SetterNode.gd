class_name SetterNode extends MonologueGraphNode


var set_type  := Property.new(DROPDOWN)
var option_id := Property.new(LINE)
var enable    := Property.new(TOGGLE)
var variable  := Property.new(DROPDOWN)
var operator  := Property.new(DROPDOWN)
var value     := Property.new(LINE)

var _control_groups = {
	"Option": [option_id, enable],
	"Variable": [variable, operator, value]
}

@onready var _option_container = $OptionContainer
@onready var _option_id_label = $OptionContainer/HBox/OptionIdLabel
@onready var _bool_label = $OptionContainer/HBox/BoolLabel
@onready var _variable_container = $VariableContainer
@onready var _variable_label = $VariableContainer/HBox/VariableLabel
@onready var _operator_label = $VariableContainer/HBox/OperatorLabel
@onready var _value_label = $VariableContainer/HBox/ValueLabel


func _ready() -> void:
	node_type = "NodeSetter"
	set_type.callers["set_items"] = [[
		{"id": 0, "text": "Option"},
		{"id": 1, "text": "Variable"},
	]]
	set_type.connect("preview", _show_group)
	
	variable.callers["set_items"] = [get_parent().variables, "Name", "ID", "Type"]
	variable.connect("preview", _value_morph)
	super._ready()


func _show_group(setter_type: Variant):
	for key in _control_groups.keys():
		for property in _control_groups.get(key):
			property.visible = key == setter_type


func _value_morph(selected_variable: Variant):
	var selected_type = ""
	for data in get_parent().variables:
		if data.get("Name") == str(selected_variable):
			selected_type = data.get("Type")
	
	match selected_type:
		"Boolean": value.morph(TOGGLE)
		"Integer": value.morph(SPINBOX)
		"String": value.morph(LINE)


func _update():
	_option_container.visible = set_type.value == "Option"
	_option_id_label.text = option_id.value
	_bool_label.text = str(enable.value)
	
	_variable_container.visible = set_type.value == "Variable"
	_variable_label.text = variable.value
	_operator_label.text = operator.value
	_value_label.text = value.value
	
	_show_group(set_type.value)
	_value_morph(variable.value)
	super._update()
