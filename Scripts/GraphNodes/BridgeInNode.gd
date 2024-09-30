## Continues the dialogue from BridgeIn node to its counterpart BridgeOut node.
@icon("res://Assets/Icons/NodesIcons/Link.svg")
class_name BridgeInNode extends MonologueGraphNode


var bridge_out_scene = preload("res://Objects/GraphNodes/BridgeOutNode.tscn")

## Spinner control which selects what number to bridge to.
@onready var number_selector: SpinBox = $MarginContainer/HBoxContainer/LinkNumber


func _ready():
	node_type = "NodeBridgeIn"
	title = node_type


func add_to(graph):
	var created = super.add_to(graph)
	var number = graph.get_free_bridge_number()
	number_selector.value = number
	
	var bridge_out = bridge_out_scene.instantiate()
	bridge_out.add_to(graph)
	bridge_out.number_selector.value = number
	created.append(bridge_out)
	
	return created


func _from_dict(dict):
	number_selector.value = dict.get("NumberSelector")
	super._from_dict(dict)


func _load_connections(_data: Dictionary, _key: String = "") -> void:
	return  # BridgeIn uses NextID covertly, not as a graph connection


func _on_position_offset_changed():
	return


func _to_fields(dict: Dictionary) -> void:
	super._to_fields(dict)
	dict["NumberSelector"] = number_selector.value
