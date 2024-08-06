## A special type of action history for handing creation and deletion
## of graph nodes.
class_name AddNodeHistory
extends ActionHistory


## Reference to the graph edit node that this action should apply to.
var graph_edit: MonologueGraphEdit

## List of node references to be deleted on undo.
var deletion_nodes: Array[MonologueGraphNode]
## Dictionary of node data to be restored on redo.
var restoration_data: Dictionary


func _init(graph: MonologueGraphEdit, nodes: Array[MonologueGraphNode]):
	graph_edit = graph
	deletion_nodes = nodes
	_undo_callback = _delete_callback_for_tracked_nodes
	_redo_callback = func() -> Array[MonologueGraphNode]:
			# the first key is the node type to re-add, it will handle
			# auxilliary creations (e.g. BridgeInNode)
			var node_name = restoration_data.keys().front()
			var node_type = restoration_data[node_name].get("$type")
			return graph_edit.add_node(node_type.trim_prefix("Node"), false)


func redo():
	# track readded nodes and repopulate their data
	deletion_nodes = super.redo()
	# iterating this way, it will go through the same order in tracked_data
	for i in range(deletion_nodes.size()):
		var node_name = restoration_data.keys()[i]
		var node_data = restoration_data[node_name]
		deletion_nodes[i].name = node_name
		deletion_nodes[i]._from_dict(node_data)
	return deletion_nodes


## This represents the undo callback after adding a node. It is defined this
## way so that it reads [member deletion_nodes] which will be updated on
## every redo, instead of bound arguments in the callback.
func _delete_callback_for_tracked_nodes():
	for node in deletion_nodes:
		restoration_data[node.name] = graph_edit.free_graphnode(node)
	return restoration_data
