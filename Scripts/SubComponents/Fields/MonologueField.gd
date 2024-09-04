## Field UI definition for side node panel control to update its graph node.
class_name MonologueField extends MarginContainer


signal field_updated(value: Variant)

const INDENT_AMOUNT = 25
const SUBLABEL_COlOR = Color("858585")

var hbox: HBoxContainer
var panel: MonologueNodePanel : set = set_panel
var property: String
var key: String
var value: Variant : set = set_value


func _init(property_name: String, dict_key: String, dict_value: Variant):
	property = property_name
	key = dict_key
	value = dict_value
	size_flags_horizontal = SIZE_EXPAND_FILL
	hbox = HBoxContainer.new()
	add_child(hbox)


func add_to_dict(dict: Dictionary) -> void:
	dict[key] = value


func build() -> MonologueField:
	return self  # override to add more specific controls


func scene(package: PackedScene, update_signal: String, setter: String,
			properties: Array = [], values: Array = []) -> MonologueField:
	var instance = package.instantiate()
	for i in properties.size():
		instance.set(properties[i], values[i])
	instance.connect(update_signal, update_value)
	var callable =  Callable(instance, setter)
	connect("field_updated", callable)
	connect("ready", callable.bind(value))
	hbox.add_child(instance)
	return self


func label(text: String) -> MonologueField:
	var new_label = Label.new()
	new_label.custom_minimum_size.x = 100
	new_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	new_label.text = text
	hbox.add_child(new_label, true)
	return self


func sublabel(text: String, prefix: String = "↳ ") -> MonologueField:
	label(text)
	var new_label = hbox.get_child(-1)
	new_label.custom_minimum_size.x += 40
	add_theme_constant_override("margin_left", INDENT_AMOUNT)
	new_label.add_theme_color_override("font_color", SUBLABEL_COlOR)
	new_label.text = prefix + new_label.text
	return self


## Sets a reference to the node panel for panel functionality.
## Useful for nested fields where immediate parent is not a node panel.
func set_panel(new_panel: MonologueNodePanel) -> MonologueField:
	panel = new_panel
	return self


## Not to be confused with update_value(). This method is to set the UI
## value without propagating to the graph node. Useful for setup or undo/redo.
func set_value(new_value: Variant) -> void:
	value = new_value
	field_updated.emit(new_value)


## Trigger a graph node and history update with the given [param new_value].
func update_value(new_value: Variant) -> bool:
	if panel._on_node_property_change([property], [new_value]):
		value = new_value
		return true
	return false
