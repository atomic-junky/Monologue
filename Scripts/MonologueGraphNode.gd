## Abstract graph node class for Monologue dialogue nodes. This should not
## be used on its own, it should be overridden to replace [member node_type].
class_name MonologueGraphNode extends GraphNode


@export var show_close_button: bool = true

# field UI scene definitions that a graph node can have
const CHECKBOX = preload("res://Objects/SubComponents/Fields/MonologueCheckBox.tscn")
const DROPDOWN = preload("res://Objects/SubComponents/Fields/MonologueDropdown.tscn")
const FILE = preload("res://Objects/SubComponents/Fields/FilePicker.tscn")
const LINE = preload("res://Objects/SubComponents/Fields/MonologueLine.tscn")
const LIST = preload("res://Objects/SubComponents/Fields/MonologueList.tscn")
const SLIDER = preload("res://Objects/SubComponents/Fields/MonologueSlider.tscn")
const SPINBOX = preload("res://Objects/SubComponents/Fields/MonologueSpinBox.tscn")
const TEXT = preload("res://Objects/SubComponents/Fields/MonologueText.tscn")
const TOGGLE = preload("res://Objects/SubComponents/Fields/MonologueToggle.tscn")

var id := Property.new(LINE, {}, UUID.v4())
var node_type: String = "NodeUnknown"


func _ready() -> void:
	title = node_type
	id.setters["copyable"] = true
	id.setters["font_size"] = 11
	id.setters["validator"] = _validate_id
	id.callers["set_label_visible"] = [false]
	for property_name in get_property_names():
		get(property_name).connect("change", change.bind(property_name))
		get(property_name).connect("display", display)


func add_to(graph) -> Array[MonologueGraphNode]:
	graph.add_child(self, true)
	return [self]


## Commits a given property's value into undo/redo history.
## Order of parameters is important due to how bind() works.
func change(old_value: Variant, new_value: Variant, property: String) -> void:
	var changes: Array[PropertyChange] = []
	changes.append(PropertyChange.new(property, old_value, new_value))
	
	var graph = get_graph_edit()
	var undo_redo = graph.undo_redo
	undo_redo.create_action("%s: %s => %s" % [property, old_value, new_value])
	var history = PropertyHistory.new(graph, graph.get_path_to(self), changes)
	undo_redo.add_prepared_history(history)
	undo_redo.commit_action()


func display() -> void:
	get_graph_edit().set_selected(self)


func get_graph_edit() -> MonologueGraphEdit:
	return get_parent()


func get_property_names() -> PackedStringArray:
	var names = PackedStringArray()
	for property in get_property_list():
		if property.class_name == "Property":
			names.append(property.name)
	return names


func _from_dict(dict: Dictionary) -> void:
	for key in dict.keys():
		var property = get(key.to_snake_case())
		if property is Property:
			property.value = dict.get(key)
	
	_load_position(dict)
	_update()  # refresh node UI after loading properties


func _load_connections(data: Dictionary, key: String = "NextID") -> void:
	var next_id = data.get(key)
	if next_id is String:
		var next_node = get_graph_edit().get_node_by_id(next_id)
		get_graph_edit().connect_node(name, 0, next_node.name, 0)


func _load_position(data: Dictionary):
	var editor_position = data.get("EditorPosition")
	if editor_position:
		position_offset.x = editor_position.get("x", randi_range(-400, 400))
		position_offset.y = editor_position.get("y", randi_range(-200, 200))


func _to_dict() -> Dictionary:
	var base_dict = {
		"$type": node_type,
		"ID": id.value,
		"EditorPosition": {
			"x": int(position_offset.x),
			"y": int(position_offset.y)
		}
	}
	_to_fields(base_dict)
	_to_next(base_dict)
	return base_dict


func _to_fields(dict: Dictionary) -> void:
	for property_name in get_property_names():
		dict[Util.to_key_name(property_name)] = get(property_name).value


func _to_next(dict: Dictionary, key: String = "NextID") -> void:
	var next_id_node = get_graph_edit().get_all_connections_from_slot(name, 0)
	dict[key] = next_id_node[0].id.value if next_id_node else -1


func _update() -> void:
	size.y = 0


func _validate_id(text: String) -> bool:
	return get_graph_edit().get_node_by_id(text) == null
