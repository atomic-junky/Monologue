## Represents a graph node property and its UI controls in Monologue.
class_name Property extends RefCounted


## Emitted if the graph node of this property should be displayed in panel.
signal display
## Emitted when the field's value is being changed and is requesting a preview.
signal preview(value: Variant)
## Emitted on show() and only if the field is visible to the user.
signal shown

## Dictionary of field method names to argument list values.
var callers: Dictionary = {}
## Reference to UI instance.
var field: MonologueField
## Scene used to instantiate the field's UI control.
var scene: PackedScene
## Dictionary of field property names to set values.
var setters: Dictionary
## UndoRedo instance for tracking property change history.
var undo_redo: HistoryHandler
## Actual value of the property.
var value: Variant
## Toggles visibility of the field instance.
var visible: bool : set = set_visible


func _init(ui_scene: PackedScene, ui_setters: Dictionary = {},
			default: Variant = "") -> void:
	scene = ui_scene
	setters = ui_setters
	value = default
	visible = true


## Invokes a given method with the given arguments on the field if present.
func invoke(method_name: String, argument_list: Array) -> Variant:
	if is_instance_valid(field):
		return field.callv(method_name, argument_list)
	return null


## Change the property's UI scene and replace the active field instance.
func morph(new_scene: PackedScene) -> void:
	scene = new_scene
	if is_instance_valid(field):
		var panel = field.get_parent()
		var child_index = field.get_index()
		field.queue_free()
		show(panel, child_index)


func propagate(new_value: Variant) -> void:
	preview.emit(new_value)
	if is_instance_valid(field):
		field.propagate(new_value)
	else:
		display.emit()


func save_value(new_value: Variant) -> void:
	if undo_redo and not Util.is_equal(value, new_value):
		undo_redo.create_action("%s => %s" % [value, new_value])
		undo_redo.add_do_property(self, "value", new_value)
		undo_redo.add_do_method(propagate.bind(new_value))
		undo_redo.add_undo_property(self, "value", value)
		undo_redo.add_undo_method(propagate.bind(value))
		undo_redo.commit_action()
	else:
		value = new_value


func set_visible(can_see: bool) -> void:
	visible = can_see
	_check_visibility()


func show(panel: Control, child_index: int = -1) -> MonologueField:
	field = scene.instantiate()
	for property in setters.keys():
		field.set(property, setters.get(property))
	
	panel.add_child(field)
	if child_index >= 0:
		panel.move_child(field, child_index)
	
	for method in callers.keys():
		field.callv(method, callers.get(method, []))
	
	field.propagate(value)
	field.connect("field_changed", preview.emit)
	field.connect("field_updated", save_value)
	_check_visibility()
	if visible:
		shown.emit()
	return field


func _check_visibility():
	if is_instance_valid(field):
		field.visible = visible
