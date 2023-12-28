@icon("res://Assets/Icons/NodesIcons/Exit.svg")

class_name EndPathNode

extends MonologueGraphNode


var next_story_name = ""


func _ready():
	node_type = "NodeEndPath"
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

func _update(panel: EndPathNodePanel = null):
	if panel != null:
		next_story_name = panel.next_story_name
