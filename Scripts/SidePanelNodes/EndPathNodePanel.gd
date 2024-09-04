@icon("res://Assets/Icons/NodesIcons/Exit.svg")

class_name EndPathNodePanel
extends MonologueNodePanel


@onready var next_story_label = $SubContainer/NextStoryContainer/NextStoryPicker

var next_story_name = ""


func _from_dict(dict):
	#id = dict.get("ID")
	next_story_name = dict.get("NextStoryName")
	
	next_story_label.text = next_story_name
	next_story_label.base_file_path = graph_node.get_parent().file_path


func _on_next_story_picker_new_file_path(file_path: String, _is_valid: bool) -> void:
	next_story_name = file_path
	_on_node_property_change(["next_story_name"], [file_path])
