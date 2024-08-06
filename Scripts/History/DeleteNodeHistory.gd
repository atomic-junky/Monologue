## Similar to AddNodeHistory but does not use [method MonologueGraphEdit.add_node]
## to restore nodes and instead uses the graph edit's add_child() method directly.
class_name DeleteNodeHistory
extends AddNodeHistory


func _init(graph: MonologueGraphEdit, nodes: Array[MonologueGraphNode]):
	super(graph, nodes)
	
	# store data of the deleted nodes immediately
	for node in nodes:
		restoration_data[node.name] = node._to_dict()
	
	# difference in this history is that the restoration directly calls
	# graph edit's add_child() for each individual node
	_redo_callback = func() -> Array[MonologueGraphNode]:
			var created_nodes: Array[MonologueGraphNode] = []
			for name in restoration_data.keys():
				var type = restoration_data[name].get("$type").trim_prefix("Node")
				var node = graph_edit.control_node.node_class_dictionary.get(type)
				var inst = node.instance_from_type()
				graph_edit.add_child(inst)
				created_nodes.append(inst)
			return created_nodes


func undo():
	return super.redo()


func redo():
	return super.undo()
