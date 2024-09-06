## Abstract graph node class for Monologue dialogue nodes. This should not
## be used on its own, it should be overridden to replace [member node_type].
class_name MonologueGraphNode extends GraphNode


# field UI scene definitions that a graph node can have
const DROPDOWN = preload("res://Objects/SubComponents/Fields/MonologueDropdown.tscn")
const FILE = preload("res://Objects/SubComponents/Fields/FilePicker.tscn")
const LINE = preload("res://Objects/SubComponents/Fields/MonologueLine.tscn")
const OPERATOR = null
const OPTION = null
const SPINNER = null
const SLIDER = null
const TEXT = preload("res://Objects/SubComponents/Fields/MonologueText.tscn")
const VARIANT = null

var id: String = UUID.v4()
var node_type: String = "NodeUnknown"
var undo_redo: HistoryHandler


func _ready():
	title = node_type
	for property_name in get_property_names():
		get(property_name).undo_redo = get_parent().undo_redo
		get(property_name).connect("display", display)


func add_to(graph) -> Array[MonologueGraphNode]:
	graph.add_child(self, true)
	return [self]


func display():
	get_parent().set_selected(self)


func get_property_names() -> PackedStringArray:
	var names = PackedStringArray()
	for property in get_property_list():
		if property.class_name == "Property":
			names.append(property.name)
	return names


func _from_dict(dict: Dictionary):
	for key in dict.keys():
		var property = get(key.to_snake_case())
		if property is Property:
			property.value = dict.get(key)
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")
	_update()  # refresh node UI after loading properties


func _load_connections(data: Dictionary, key: String = "NextID"):
	var next_id = data.get(key)
	if next_id is String:
		var next_node = get_parent().get_node_by_id(next_id)
		get_parent().connect_node(name, 0, next_node.name, 0)


func _to_dict() -> Dictionary:
	var base_dict = {
		"$type": node_type,
		"ID": id,
		"EditorPosition": {
			"x": int(position_offset.x),
			"y": int(position_offset.y)
		}
	}
	
	#for field in get_fields():
		#field.add_to_dict(base_dict, true)
	_to_next(base_dict)
	return base_dict


func _to_next(dict: Dictionary, key: String = "NextID") -> void:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	dict[key] = next_id_node[0].id if next_id_node else -1


func _update(_panel = null):
	pass


func _common_update(_panel = null):
	size.y = 0
	
	if _panel:
		id = _panel.id


func _connect_to_panel(sgnl):
	sgnl.connect(_common_update)
