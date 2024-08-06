## A special type of action history for handing creation and deletion
## of graph nodes.
class_name AddNodeHistory
extends ActionHistory


## Reference to the graph edit node that this action should apply to.
var graph_edit: MonologueGraphEdit
## The node's name, for graph connections to know what to point to in redo.
var node_name: String
## The node's data.
var node_data: Dictionary


func _init(graph: MonologueGraphEdit, name: String, 
		undo_func: Callable, redo_func: Callable):
	super(undo_func, redo_func)
	graph_edit = graph
	node_name = name


func undo():
	# when node is deleted, save its values at the time for the redo
	var dictionary = super.undo()
	node_data = dictionary


func redo():
	# repopulate node data
	var readded_node = super.redo()
	readded_node._from_dict(node_data)
	readded_node.name = node_name
	
	# when you undo a node creation, it deletes the created node
	# so when you redo, it creates a new node which is different from the undo
	# therefore we have to update the undo callback to reference this redo node
	_undo_callback = graph_edit.free_graphnode.bind(readded_node)
