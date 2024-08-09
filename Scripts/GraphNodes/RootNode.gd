@icon("res://Assets/Icons/NodesIcons/Root.svg")

class_name RootNode
extends MonologueGraphNode


var speakers: set = _set_speakers, get = _get_speakers
var variables: set = _set_variables, get = _get_variables


func _ready():
	node_type = "NodeRoot"
	title = node_type


func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_id_node[0].id if next_id_node and next_id_node[0] else -1,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict):
	id = dict.get("ID")
	
	var _pos = dict.get("EditorPosition")
	position_offset.x = _pos.get("x")
	position_offset.x = _pos.get("y")


func _update(panel: RootNodePanel = null):
	if panel != null:
		if speakers.size() != panel.characters_container.get_child_count() or \
				variables.size() != panel.variables_container.get_child_count():
			panel.reload_characters()
			panel.reload_variables()
		else:
			panel.update_controls()


func _set_speakers(new_speakers):
	get_parent().speakers = new_speakers


func _set_variables(new_variables):
	get_parent().variables = new_variables


func _get_speakers():
	return get_parent().speakers


func _get_variables():
	return get_parent().variables
