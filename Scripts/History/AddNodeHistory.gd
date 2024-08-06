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
## Dictionary of inbound_connections to be restored on redo.
var inbound_connections: Dictionary
## Dictionary of out_connections to be restored on redo.
var outbound_connections: Dictionary


func _init(graph: MonologueGraphEdit, nodes: Array[MonologueGraphNode]):
	graph_edit = graph
	deletion_nodes = nodes
	
	# store node data
	for node in nodes:
		_record_connections(node)
		restoration_data[node.name] = node._to_dict()
	
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
		_restore_connections(node_name)
	return deletion_nodes


## This represents the undo callback after adding a node. It is defined this
## way so that it reads [member deletion_nodes] which will be updated on
## every redo, instead of bound arguments in the callback.
func _delete_callback_for_tracked_nodes():
	for i in deletion_nodes.size():
		var node = deletion_nodes[i]
		# restore node reference if it was broken by some other action
		# this can be caused by many undo/redo re-creating the node, thus our
		# reference here becomes outdated, but we can get it back by searching
		# the graph for its node name
		if not node:
			node = graph_edit.get_node(restoration_data.keys()[i])
		_record_connections(node)  # record connections first before freeing!!
		restoration_data[node.name] = graph_edit.free_graphnode(node)
	return restoration_data


## Quick method to record all inbound and outbound connections of a given node.
func _record_connections(node: MonologueGraphNode):
	inbound_connections[node.name] = graph_edit.get_all_inbound_connections(node.name)
	outbound_connections[node.name] = graph_edit.get_all_outbound_connections(node.name)


## Restore graph connections to a given node name.
func _restore_connections(node_name: String):
	for co in inbound_connections.get(node_name) + outbound_connections.get(node_name):
		graph_edit.connect_node(co.get("from_node"), co.get("from_port"),
				co.get("to_node"), co.get("to_port"))
