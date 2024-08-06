@icon("res://Assets/Icons/NodesIcons/Comment.png")

class_name CommentNode

extends MonologueGraphNode


@onready var comment_edit = $MainContainer/CommentEdit


static func instance_from_type() -> MonologueGraphNode:
	return preload("res://Objects/GraphNodes/CommentNode.tscn").instantiate()


func _to_dict() -> Dictionary:
	node_type = "NodeComment"
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


func _on_close_request():
	queue_free()
