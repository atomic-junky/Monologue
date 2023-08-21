extends GraphNode


var _node_dict: Dictionary

var id = UUID.v4()
var node_type = "NodeBridgeOut"
@onready var number_selector = $MarginContainer/HBoxContainer/LinkNumber


func _ready():
	title = node_type


func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_id_node[0].id if next_id_node else -1,
		"NumberSelector": number_selector.value,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict):
	_node_dict = dict
	
	id = dict.get("ID")
	number_selector.value = dict.get("NumberSelector")
	
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")


func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()
