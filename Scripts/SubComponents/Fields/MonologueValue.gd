## Handles fields that can change based on variable type (bool, int, String).
class_name MonologueValue extends MonologueField


const DEFAULT_COLOR = Color("929292")
const BOOLEAN: String = "Boolean"
const INTEGER: String = "Integer"
const STRING: String = "String"
const FILE: String = "File"

var base_path: String : set = set_path
var filter_definitions: Dictionary
var variable: MonologueOptionButton
var value_field: Control


func _init(dict_value: Variant):
	super("value", "Value", dict_value)
	label("Value")
	connect("tree_exiting", func(): if value_field: value_field.queue_free())


func add_to_dict(dict: Dictionary, auto_free: bool = false) -> void:
	if value_field is MonologueField:
		dict[value_field.json_key] = value_field.value
	else:
		dict[json_key] = null
	
	if auto_free: queue_free()


func build() -> MonologueField:
	if value_field:
		value_field.queue_free()
	var index = variable.option_button.selected
	var type = variable.option_button.get_item_metadata(index)
	
	match type:
		BOOLEAN: value_field = MonologueCheckButton \
				.new(property, json_key, value).build()
		INTEGER: value_field = MonologueSpinBox \
				.new(property, json_key, value).build()
		STRING: value_field = MonologueLineEdit \
				.new(property, json_key, value).build()
		FILE:
			var filter_dict = filter_definitions.get(variable, {})
			var filter_list = filter_dict.get(index, [])
			value_field = MonologueField.new(property, json_key, value) \
				.scene(GlobalVariables.FILE_EDIT, "new_file_path",
					"set_variant", ["base_file_path", "filters"],
					[base_path, filter_list])
		_:
			value_field = Label.new()
			value_field.text = "Please select a variable first"
			value_field.add_theme_color_override("font_color", DEFAULT_COLOR)
	
	if panel and value_field is MonologueField:
		value_field.set_panel(panel)
	hbox.add_child(value_field)
	return self


func set_panel(new_panel: MonologueNodePanel) -> MonologueField:
	super.set_panel(new_panel)
	if value_field is MonologueField:
		value_field.set_panel(new_panel)
	return self


func set_path(path: String) -> MonologueField:
	base_path = path
	return self


func set_value(new_value: Variant) -> void:
	if value_field:
		value_field.value = new_value
		value = value_field.value
	else:
		super.set_value(new_value)


## Intended to be called once per given [param option_button], establishes
## the "item_selected" signal to rebuild the value field. [param filter_dict]
## should be in this format: { <<selected index>>: <<filter array>> }
func vary(dropdown: MonologueOptionButton,
			filter_dict: Dictionary = {}) -> MonologueField:
	var callback = func(_idx):
		variable = dropdown
		build()
	variable = dropdown
	filter_definitions[variable] = filter_dict
	variable.option_button.connect("item_selected", callback)
	return self
