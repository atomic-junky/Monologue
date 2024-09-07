## Side panel which displays graph node details. This panel should not contain
## references to MonologueControl or GraphEditSwitcher.
class_name SidePanelNodeDetails extends PanelContainer


@onready var fields_container = $MarginContainer/Scroller/VBox/FieldsContainer
@onready var line_edit_id = $MarginContainer/Scroller/VBox/HBox/LineEditID
@onready var ribbon_scene = preload("res://Objects/SubComponents/Ribbon.tscn")
@onready var node_panel = preload("res://Scripts/MonologueNodePanel.gd")

var selected_node: MonologueGraphNode


func _ready():
	GlobalSignal.add_listener("close_panel", _on_close_button_pressed)
	hide()


func on_graph_node_deselected(_node):
	for field in fields_container.get_children():
		field.queue_free()
	hide()


func on_graph_node_selected(node: MonologueGraphNode, bypass: bool = false):
	if not bypass:
		var graph_edit = node.get_parent()
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(node) and not graph_edit.moving_mode and \
				graph_edit.selected_nodes.size() == 1:
			graph_edit.active_graphnode = node
		else:
			graph_edit.active_graphnode = null
			return
	
	line_edit_id.text = node.id
	selected_node = node
	node._update()
	
	for property_name in node.get_property_names():
		var field = node.get(property_name).show(fields_container)
		field.set_label_text(property_name.capitalize())
	
	show()


## If the side panel for the node is visible, release the focus so that
## text controls trigger the focus_exited() signal to update.
func refocus(node: MonologueGraphNode) -> void:
	if visible and selected_node == node:
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
			focus_owner.grab_focus()


func _on_line_edit_id_text_changed(new_id):
	if selected_node:
		var graph = selected_node.get_parent()
		if graph.get_node_by_id(new_id):
			line_edit_id.text = selected_node.id
		else:
			selected_node.id = new_id


func _on_tfh_button_pressed() -> void:
	GlobalSignal.emit("test_trigger", [selected_node.id])


func _on_id_copy_pressed() -> void:
	DisplayServer.clipboard_set(line_edit_id.text)
	var ribbon = ribbon_scene.instantiate()
	ribbon.position = get_viewport().get_mouse_position()
	get_window().add_child(ribbon)


func _on_close_button_pressed(node: MonologueGraphNode = null) -> void:
	if not node or selected_node == node:
		selected_node.get_parent().set_selected(null)
