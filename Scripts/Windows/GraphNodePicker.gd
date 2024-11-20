class_name GraphNodePicker extends Window


var from_node: String
var from_port: int
var release = null
var graph_release = null
var center = null


func _ready():
	hide()
	force_native = true
	GlobalSignal.add_listener("enable_picker_mode", _on_enable_picker_mode)

func _on_enable_picker_mode(node: String = "", port: int = -1, release_pos = null, graph_release_pos = null, center_pos = null):
	from_node = node
	from_port = port
	release = release_pos
	graph_release = graph_release_pos
	center = center_pos
	
	if from_node:
		position = Vector2i(release) + get_tree().get_root().position
	show()


func close() -> void:
	hide()


func flush() -> void:
	from_node = ""
	from_port = -1
	release = null
	graph_release = null
	center = null


func _on_close_requested() -> void: close()
func _on_cancel_button_pressed() -> void: close()
func _on_create_button_pressed() -> void: close()
