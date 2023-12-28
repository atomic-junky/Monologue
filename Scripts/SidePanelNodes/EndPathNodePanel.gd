@icon("res://Assets/Icons/NodesIcons/Exit.svg")

class_name EndPathNodePanel

extends MonologueNodePanel


@onready var next_story_label = $SubContainer/LineEdit

var next_story_name = ""


func _from_dict(dict):
	id = dict.get("ID")
	next_story_name = dict.get("NextStoryName")
	
	next_story_label.text = next_story_name


func _on_line_edit_text_changed(new_text):
	next_story_name = new_text	
	change.emit(self)
