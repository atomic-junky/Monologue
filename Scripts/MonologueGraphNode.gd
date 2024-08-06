## Abstract graph node class for Monologue dialogue nodes. This should not
## be used on its own, it should be overridden to replace [member node_type].
class_name MonologueGraphNode
extends GraphNode


var id: String = UUID.v4()
var node_type: String = "NodeUnknown"


## Creates this graph node in the given graph edit.
## Returns an instance of itself as a result of the node creation.
func add_to_graph(graph_edit: MonologueGraphEdit) -> Array[MonologueGraphNode]:
	graph_edit.add_child(self, true)
	graph_edit.center_node(self)
	return [self]


## Should be overridden to instantiate its corresopnding node type.
static func instance_from_type() -> MonologueGraphNode:
	return null


func _from_dict(_dict: Dictionary):
	pass


func _to_dict():
	pass


func _update(_panel = null):
	pass


func _common_update(_panel = null):
	size.y = 0
	
	if _panel:
		id = _panel.id


func _connect_to_panel(sgnl):
	sgnl.connect(_update)
	sgnl.connect(_common_update)
