## Side panel which displays graph node details. This panel should not contain
## references to MonologueControl or GraphEditSwitcher.
class_name SidePanel extends PanelContainer


@onready var fields_container = $OuterMargin/Scroller/InnerMargin/VBox/Fields
@onready var topbox = $OuterMargin/Scroller/InnerMargin/VBox/HBox
@onready var ribbon_scene = preload("res://Objects/SubComponents/Ribbon.tscn")
@onready var collapsible_field = preload("res://Objects/SubComponents/CollapsibleField.tscn")

var id_field: MonologueField
var selected_node: MonologueGraphNode


func _ready():
	GlobalSignal.add_listener("close_panel", _on_close_button_pressed)
	hide()


func on_graph_node_deselected(_node):
	for field in fields_container.get_children():
		field.queue_free()
	if is_instance_valid(id_field):
		id_field.queue_free()
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
	
	selected_node = node
	node._update()
	
	if not node.is_editable():
		return
		
	
	var items = node._get_field_groups()
	var already_invoke := []
	
	for item in items:
		if item is String:
			var field = node.get(item).show(fields_container)
			field.set_label_text(item.capitalize())
			already_invoke.append(item)
		else:
			for group in item:
				var fields = item[group]
				var cf: CollapsibleField = collapsible_field.instantiate()
				fields_container.add_child(cf)
				cf.set_title(group)
				
				for field_name in fields:
					for property_name in node.get_property_names():
						if field_name != property_name:
							continue
						
						var field = node.get(property_name).show(fields_container)
						field.set_label_text(property_name.capitalize())
						
						fields_container.remove_child(field)
						cf.add_item(field)
						already_invoke.append(property_name)
	
	for property_name in node.get_property_names():
		if property_name in already_invoke:
			continue
		
		if property_name == "id":
			id_field = node.get(property_name).show(topbox, 0)
		else:
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


func _on_tfh_button_pressed() -> void:
	GlobalSignal.emit("test_trigger", [selected_node.id.value])


func _on_close_button_pressed(node: MonologueGraphNode = null) -> void:
	if not node or selected_node == node:
		selected_node.get_parent().set_selected(null)
