## Continues the dialogue from BridgeIn node to its counterpart BridgeOut node.
@icon("res://Assets/Icons/NodesIcons/Link.svg")
class_name BridgeInNode extends MonologueGraphNode


var bridge_out_scene = preload("res://Objects/GraphNodes/BridgeOutNode.tscn")

## Spinner control which selects what number to bridge to.
@onready var number_selector: SpinBox = $MarginContainer/HBoxContainer/LinkNumber


func _ready():
	node_type = "NodeBridgeIn"
	title = node_type


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


func add_to(graph):
	var created = super.add_to(graph)
	var number = graph.get_free_bridge_number()
	number_selector.value = number
	
	var bridge_out = bridge_out_scene.instantiate()
	bridge_out.add_to(graph)
	bridge_out.number_selector.value = number
	created.append(bridge_out)
	
	return created


func _load_connections(data: Dictionary, key: String = "") -> void:
	return  # BridgeIn uses NextID covertly, not as a graph connection


func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()


func _on_position_offset_changed():
	return
