## Handles fields that can change based on variable type (bool, int, String).
class_name MonologueValue extends MonologueField


const DEFAULT_COLOR = Color("929292")
const BOOLEAN: String = "Boolean"
const INTEGER: String = "Integer"
const STRING: String = "String"
const FILE: String = "File"

var variable: MonologueOptionButton
var value_field: Control


func _init(dict_value: Variant):
	super("value", "Value", dict_value)
	label("Value")


func add_to_dict(dict: Dictionary) -> void:
	if value_field is MonologueField:
		dict[value_field.key] = value_field.value
	else:
		dict[key] = null


func build() -> MonologueField:
	if value_field:
		value_field.queue_free()
	var index = variable.option_button.selected
	var type = variable.option_button.get_item_metadata(index)
	
	match type:
		BOOLEAN: value_field = MonologueCheckButton.new(property, key, value)
		INTEGER: value_field = MonologueSpinBox.new(property, key, value)
		STRING:  value_field = MonologueLineEdit.new(property, key, value)
		_:
			value_field = Label.new()
			value_field.text = "Please select a variable first"
			value_field.add_theme_color_override("font_color", DEFAULT_COLOR)
	hbox.add_child(value_field)
	return self


func set_value(new_value: Variant) -> void:
	if value_field:
		value_field.value = new_value
		value = value_field.value
	else:
		super.set_value(new_value)


## Intended to be called once per given [param option_button], establishes
## the "item_selected" signal to rebuild the value field.
func vary(dropdown: MonologueOptionButton) -> MonologueField:
	var callback = func():
		variable = dropdown
		build()
	variable = dropdown
	variable.option_button.connect("item_selected", callback)
	return self
