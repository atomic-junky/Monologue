extends GraphNode


@onready var comment_edit = $MainContainer/CommentEdit

var id = UUID.v4()
var node_type = "NodeComment"


func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
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
