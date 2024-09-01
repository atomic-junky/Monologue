class_name GraphNodeSelector extends Window


var node: String
var port: int
var location: Vector2


func _ready() -> void:
	hide()
	GlobalSignal.add_listener("enable_picker_mode", enable_picker_mode)
	GlobalSignal.add_listener("disable_picker_mode", disable_picker_mode)


## Start the picker mode from a given node and port. Picker mode is where
## a new node is created from another node through a connection to empty.
func enable_picker_mode(from_node: String, from_port: int,
			release_position: Vector2, center_position: Vector2) -> void:
	position = Vector2i(release_position) - size / 2 * Vector2i(1, 0)
	location = center_position
	node = from_node
	port = from_port
	GlobalSignal.emit("show_dimmer")
	show()


## Exit picker mode. Picker mode is where a new node is created from another
## node through a connection to empty.
func disable_picker_mode() -> void:
	GlobalSignal.emit("hide_dimmer")
	hide()


func _on_selector_btn_pressed(node_type: String) -> void:
	GlobalSignal.emit("add_graph_node", [node_type, self])
