class_name PropertyHistory
extends MonologueHistory


## Graph that owns the node whose properties have changed.
var graph_edit: MonologueGraphEdit
## Name of the graph node in the [member graph_edit].
var node_name: String
## List of property changes to make on [member node_name].
var changes: Array[PropertyChange]


func _init(node: MonologueGraphNode, change_list: Array[PropertyChange]):
	graph_edit = node.get_parent()
	node_name = node.name
	changes = change_list
	
	_undo_callback = revert_properties
	_redo_callback = change_properties


func change_properties():
	var node: MonologueGraphNode = graph_edit.get_node(node_name)
	for change in changes:
		node[change.property].value = change.after
		node[change.property].propagate(change.after)


func revert_properties():
	var node: MonologueGraphNode = graph_edit.get_node(node_name)
	for change in changes:
		node[change.property].value = change.before
		node[change.property].propagate(change.before)
