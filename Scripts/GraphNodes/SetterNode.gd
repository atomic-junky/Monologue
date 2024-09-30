class_name SetterNode extends MonologueGraphNode


var set_type  := Property.new(DROPDOWN, {}, "Option")
var option_id := Property.new(LINE)
var enable    := Property.new(TOGGLE)
var variable  := Property.new(DROPDOWN)
var operator  := Property.new(DROPDOWN, {}, "=")
var value     := Property.new(LINE)
var image     := Property.new(FILE, { "filters": FilePicker.IMAGE })

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
		{ "id": 0, "text": "Option"     },
		{ "id": 1, "text": "Variable"   },
		{ "id": 3, "text": "Timer"      },
	]]
	set_type.connect("change", func(_old, new): _show_group(new))
	set_type.connect("preview", _show_group)
	option_id.connect("preview", _option_id_label.set_text)
	enable.connect("preview", func(e): _bool_label.text = str(e))
	
	variable.connect("preview", _variable_label.set_text)
	variable.connect("preview", _value_morph)
	operator.callers["set_items"] = [[
		{ "id": 0, "text": "="  },
		{ "id": 1, "text": "+=" },
		{ "id": 2, "text": "-=" },
		{ "id": 3, "text": "*=" },
		{ "id": 4, "text": "/=" },
	]]
	operator.connect("preview", _operator_label.set_text)
	operator.connect("shown", _value_morph)
	value.connect("preview", func(v): _value_label.text = str(v))
	
	_show_group(set_type.value)
	super._ready()


func _default_text(new_value: Variant, default: String) -> String:
	var is_not_string = new_value is not String
	return str(new_value) if is_not_string or new_value != "" else default


func _from_dict(dict: Dictionary) -> void:
	super._from_dict(dict)
	_show_group(set_type.value)


## Just a fun thing to do as a throwback to the old CustomAction.
func _get_emoji() -> String:
	match set_type.value:
		"Option":     return "❔ "
		"Variable":   return "⚙️ "
		"Background": return "🖼️ "
		"Timer":      return "⏱️ "
		_:            return ""


## Returns the variable's typestring from the graph edit.
func _get_variable_type(variable_name: String) -> String:
	for data in get_graph_edit().variables:
		if data.get("Name") == variable_name:
			return data.get("Type")
	return ""


## Reset the variable dropdown to the first value and return its type.
func _reset_variable() -> String:
	if get_graph_edit().variables:
		variable.value = get_graph_edit().variables[0].get("Name")
		return get_graph_edit().variables[0].get("Type")
	else:
		variable.value = ""
		return ""


func _show_group(setter_type: Variant) -> void:
	for key in _control_groups.keys():
		for property in _control_groups.get(key):
			property.visible = key == setter_type
	title = "%s%s" % [_get_emoji(), node_type]
	_update(setter_type)


func _value_morph(selected_name: Variant = variable.value) -> void:
	var selected_type = _get_variable_type(selected_name)
	if not selected_type:
		selected_type = _reset_variable()
	
	match selected_type:
		"Boolean":
			operator.invoke("disable_items", [[1, 2, 3, 4]])
			value.morph(TOGGLE)
			if not value.value:
				value.value = false
		"Integer":
			operator.invoke("disable_items", [[]])
			value.morph(SPINBOX)
			if not value.value:
				value.value = 0
		"String":
			operator.invoke("disable_items", [[1, 2, 3, 4]])
			value.morph(LINE)


func _update(setter_type: Variant = set_type.value) -> void:
	_option_container.visible = setter_type == "Option"
	_option_id_label.text = _default_text(option_id.value, "option id")
	_bool_label.text = _default_text(enable.value, "false")
	
	_variable_container.visible = setter_type == "Variable"
	variable.callers["set_items"] = \
		[get_graph_edit().variables, "Name", "ID", "Type"]
	_value_morph(variable.value)
	_variable_label.text = _default_text(variable.value, "variable")
	_operator_label.text = _default_text(operator.value, "operator")
	_value_label.text = _default_text(value.value, "value")
	
	super._update()
