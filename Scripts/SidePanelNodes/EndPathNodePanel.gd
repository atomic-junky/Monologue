@icon("res://Assets/Icons/NodesIcons/Exit.svg")

class_name EndPathNodePanel
extends MonologueNodePanel


@onready var next_story_label = $SubContainer/LineEdit

var next_story_name = ""


func _from_dict(dict):
	id = dict.get("ID")
	next_story_name = dict.get("NextStoryName")
	
	next_story_label.text = next_story_name


func _on_next_story_focus_exited():
	_on_next_story_text_submitted(next_story_label.text)


func _on_next_story_text_submitted(new_text):
	next_story_name = new_text
	_on_node_property_change(["next_story_name"], [new_text])
