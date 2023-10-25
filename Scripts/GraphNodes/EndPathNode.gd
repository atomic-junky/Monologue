@icon("res://Assets/Icons/NodesIcons/Exit.svg")

class_name EndPathNode

extends GraphNode


var node_type = "NodeEndPath"
var id = UUID.v4()
var next_story_name = ""


func _ready():
	title = node_type


func _to_dict():
	return {
		"$type": node_type,
		"ID": id,
		"NextStoryName": next_story_name,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict):
	id = dict.get("ID")
	next_story_name = dict.get("NextStoryName", "")


func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()
