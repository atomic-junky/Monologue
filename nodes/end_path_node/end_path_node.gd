@icon("res://ui/assets/icons/exit.svg")
class_name EndPathNode extends MonologueGraphNode


const NOTE = "Note: Variables are kept with their values between stories when you use this node."

var next_story := Property.new(LINE, { "note_text": NOTE })


func _ready():
	node_type = "NodeEndPath"
	super._ready()


func _from_dict(dict: Dictionary):
	next_story.value = dict.get("NextStoryName", "")  # backwards compatibility
	super._from_dict(dict)


func _on_close_request():
	queue_free()
	get_parent().clear_all_empty_connections()
