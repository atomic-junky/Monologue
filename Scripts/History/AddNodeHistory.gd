## A special type of action history for handing creation and deletion
## of graph nodes.
class_name AddNodeHistory
extends ActionHistory


## Reference to the graph edit node that this action should apply to.
var graph_edit: GraphEdit
## The node's data.
var node_data: Dictionary


func _init(graph: GraphEdit, undo_function: Callable, redo_function: Callable):
	super(undo_function, redo_function)
	graph_edit = graph


func undo():
	# when node is deleted, save its values at the time for the redo
	var dictionary = super.undo()
	node_data = dictionary


func redo():
	# repopulate node data
	var readded_node = super.redo()
	readded_node._from_dict(node_data)
	
	# when you undo a node creation, it deletes the created node
	# so when you redo, it creates a new node which is different from the undo
	# therefore we have to update the undo callback to delete this redo node
	_undo_callback = graph_edit.free_graphnode.bind(readded_node)
