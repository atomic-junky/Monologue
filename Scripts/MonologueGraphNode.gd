## Abstract graph node class for Monologue dialogue nodes. This should not
## be used on its own, it should be overridden to replace [member node_type].
class_name MonologueGraphNode
extends GraphNode


var MonologueLineEdit: MonologueField :
	get(): return preload("res://Objects/SubComponents/Fields/MonologueLineEdit.tscn").instantiate()
var MonologueTextEdit: MonologueField :
	get(): return preload("res://Objects/SubComponents/Fields/MonologueTextEdit.tscn").instantiate()
var MonologueOptionButton: MonologueField :
	get(): return preload("res://Objects/SubComponents/Fields/MonologueOptionButton.tscn").instantiate()
var MonologueFilePicker: MonologueField :
	get(): return preload("res://Objects/SubComponents/Fields/MonologueLineEdit.tscn").instantiate()
var MonologueSeparator: HSeparator :
	get(): return HSeparator.new()

var id: String = UUID.v4()
var node_type: String = "NodeUnknown"

var dict: Dictionary = {}


func add_to(graph) -> Array[MonologueGraphNode]:
	graph.add_child(self, true)
	return [self]


func _load(new_dict: Dictionary) -> void:
	dict = new_dict
	self._from_dict(dict)
	
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")


func _update_fields(fields: Dictionary) -> void:
	for field in fields.keys():
		dict[field] = fields[field]
	
	self._from_dict(dict)
	size.y = 0


func _from_dict(_dict: Dictionary):
	pass


func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
	var base_dict: Dictionary = {
		"$type": node_type,
		"NextID": next_id_node[0].id if next_id_node else -1,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}
	
	return base_dict.merged(dict)


func _update(_panel = null):
	pass


func _common_update(_panel = null):
	size.y = 0
	
	if _panel:
		id = _panel.id


func _connect_to_panel(sgnl):
	sgnl.connect(_update)
	sgnl.connect(_common_update)
