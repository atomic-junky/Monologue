## Continues the dialogue from BridgeIn node to its counterpart BridgeOut node.
@icon("res://Assets/Icons/NodesIcons/Link.svg")

class_name BridgeInNode
extends MonologueGraphNode


@onready var bridge_out = preload("res://Objects/GraphNodes/BridgeOutNode.tscn")
## Spinner control which selects what number to bridge to.
@onready var number_selector: SpinBox = $MarginContainer/HBoxContainer/LinkNumber


func _ready():
	node_type = "NodeBridgeIn"
	title = node_type


## BridgeIn is always created first in regards to its BridgeOut counterpart.
## When creating BridgeIn, automatically create BridgeOut.
func add_to_graph(graph_edit: MonologueGraphEdit) -> Array[MonologueGraphNode]:
	var created_nodes: Array[MonologueGraphNode] = []
	created_nodes = super.add_to_graph(graph_edit)
	var number = graph_edit.get_free_bridge_number()
	created_nodes[0].number_selector.value = number
	created_nodes[0].position_offset.x -= created_nodes[0].size.x / 2 + 10
	
	var out_node = bridge_out.instantiate() # create counterpart
	out_node.add_to_graph(graph_edit) # ignore return, use out_node
	out_node.number_selector.value = number
	out_node.position_offset.x += out_node.size.x / 2 + 10
	created_nodes.append(out_node)
	return created_nodes


func _to_dict() -> Dictionary:
	var next_node = get_parent().get_linked_bridge_node(number_selector.value)
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_node.id if next_node else -1,
		"NumberSelector": number_selector.value,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict):
	id = dict.get("ID")
	number_selector.value = dict.get("NumberSelector")
	
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")


func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()


func _on_position_offset_changed():
	return
