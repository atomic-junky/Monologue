@icon("res://Assets/Icons/NodesIcons/Comment.png")
class_name CommentNode extends MonologueGraphNode


@onready var comment_edit = $MainContainer/CommentEdit


func _ready() -> void:
	node_type = "NodeComment"
	super._ready()


func _to_dict() -> Dictionary:
	return {
		"$type": node_type,
		"ID": id,
		"Comment": comment_edit.text,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}

func _from_dict(dict: Dictionary) -> void:
	id = dict.get("ID")
	comment_edit.text = dict.get("Comment")
	
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")


func _on_close_request():
	queue_free()
