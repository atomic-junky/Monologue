## Continues the dialogue from BridgeIn node to its counterpart BridgeOut node.
@icon("res://Assets/Icons/NodesIcons/Link.svg")

class_name BridgeInNode
extends MonologueGraphNode

## Spinner control which selects what number to bridge to.
@onready var number_selector: SpinBox = $MarginContainer/HBoxContainer/LinkNumber


func _ready():
	node_type = "NodeBridgeIn"
	title = node_type


## BridgeIn is always created first in regards to its BridgeOut counterpart.
## When creating BridgeIn, automatically create BridgeOut.
func add_to_graph(graph_edit: MonologueGraphEdit) -> MonologueGraphNode:
	var in_node = super.add_to_graph(graph_edit)
	var number = graph_edit.get_free_bridge_number()
	in_node.number_selector.value = number
	in_node.position_offset.x -= in_node.size.x / 2 + 10
	
	# create counterpart node
	var out_node = BridgeOutNode.instance_from_type()
	out_node.add_to_graph(graph_edit)
	out_node.number_selector.value = number
	out_node.position_offset.x += out_node.size.x / 2 + 10
	
	return in_node


static func instance_from_type() -> MonologueGraphNode:
	return preload("res://Objects/GraphNodes/BridgeInNode.tscn").instantiate()


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
