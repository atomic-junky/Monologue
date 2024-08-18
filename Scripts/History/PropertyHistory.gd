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
	refresh_panel(node)


func revert_properties():
	var node: MonologueGraphNode = graph_edit.get_node(node_name)
	for change in changes:
		node[change.property] = change.before
	refresh_panel(node)


## If currently opened side panel is for the given node, refresh it.
## Otherwise, select that node to open its side panel.
func refresh_panel(node: MonologueGraphNode):
	var side_panel = graph_edit.control_node.side_panel_node
	if side_panel.visible and side_panel.selected_node == node:
		# update existing controls using panel's _from_dict()
		side_panel.current_panel._from_dict(node._to_dict())
		side_panel.current_panel.change.emit(side_panel.current_panel)
	else:
		graph_edit.set_selected(node)
