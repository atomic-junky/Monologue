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
		node[change.property] = change.after
	node._update()
	refresh_panel(node)


func revert_properties():
	var node: MonologueGraphNode = graph_edit.get_node(node_name)
	for change in changes:
		node[change.property] = change.before
	node._update()
	refresh_panel(node)


## If currently opened side panel is for the given node, refresh it.
func refresh_panel(node: MonologueGraphNode):
	var side_panel = graph_edit.control_node.side_panel_node
	side_panel.clear_current_panel()
	if graph_edit.active_graphnode == node:
		side_panel.on_graph_node_selected(node, true)
	else:
		graph_edit.set_selected(node)
