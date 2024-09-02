## Side panel which displays graph node details. This panel should not contain
## references to MonologueControl or GraphEditSwitcher.
class_name SidePanelNodeDetails extends PanelContainer


var panel_dictionary = {
	"NodeRoot": preload("res://Objects/SidePanelNodes/RootNodePanel.tscn"),
	"NodeSentence": preload("res://Objects/SidePanelNodes/SentenceNodePanel.tscn"),
	"NodeChoice": preload("res://Objects/SidePanelNodes/ChoiceNodePanel.tscn"),
	"NodeDiceRoll": preload("res://Objects/SidePanelNodes/DiceRollNodePanel.tscn"),
	"NodeEndPath": preload("res://Objects/SidePanelNodes/EndPathNodePanel.tscn"),
	"NodeCondition": preload("res://Objects/SidePanelNodes/ConditionNodePanel.tscn"),
	"NodeAction": preload("res://Objects/SidePanelNodes/ActionNodePanel.tscn"),
	"NodeEvent": preload("res://Objects/SidePanelNodes/ConditionNodePanel.tscn")
}

@onready var control_node = $"../../../../.."
@onready var id_line_edit = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer/LineEditID
@onready var panel_container = $MarginContainer/ScrollContainer/PanelContainer
@onready var ribbon_scene = preload("res://Objects/SubComponents/Ribbon.tscn")
@onready var node_panel = preload("res://Scripts/MonologueNodePanel.gd")

var current_panel: MonologueNodePanel
var selected_node: MonologueGraphNode


func _ready():
	GlobalSignal.add_listener("clear_current_panel", clear_current_panel)
	GlobalSignal.add_listener("refresh_panel", refresh_panel)
	GlobalSignal.add_listener("update_option_next_id", update_option_next_id)
	hide()


func clear_current_panel(node: MonologueGraphNode = null) -> void:
	if current_panel and (not node or current_panel.graph_node == node):
		current_panel.queue_free()
		current_panel = null
		if node: hide()


func on_graph_node_selected(node: MonologueGraphNode, bypass: bool = false):
	var new_panel: MonologueNodePanel = node_panel.new()
	
	if not bypass:
		var graph_edit = node.get_parent()
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(node) and not graph_edit.moving_mode and \
				graph_edit.selected_nodes.size() == 1:
			graph_edit.active_graphnode = node
		else:
			graph_edit.active_graphnode = null
			return
	
	id_line_edit.text = node.id
	
	clear_current_panel()
	new_panel.side_panel = self
	new_panel.graph_node = node
	new_panel.id_line_edit = id_line_edit
	current_panel = new_panel
	selected_node = node
	panel_container.add_child(new_panel)
	new_panel._from_dict(node._to_dict())
	# this is for undo/redo to propagate gui updates back to its graph node
	node._update()
	
	show()


## If the side panel for the node is visible, release the focus so that
## text controls trigger the focus_exited() signal to update.
func refocus(node: MonologueGraphNode) -> void:
	if visible and selected_node == node:
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
			focus_owner.grab_focus()


## Refresh the current panel for the given node, or select it if not visible.
func refresh_panel(node: MonologueGraphNode):
	if visible and selected_node == node:
		# update existing controls using panel's _from_dict()
		current_panel._from_dict(node._to_dict())
		current_panel.change.emit(current_panel)
	else:
		node.get_parent().set_selected(node)


func update_option_next_id(choice_node: ChoiceNode, port: int) -> void:
	if current_panel and current_panel.graph_node == choice_node:
		var option_id = choice_node.options[port].get("ID")
		var option_node = current_panel.get_option_node(option_id)
		if option_node:
			option_node.next_id = choice_node.options[port].get("NextID")


func _on_graph_edit_child_exiting_tree(_node):
	hide()


func on_graph_node_deselected(_node):
	hide()


func _on_texture_button_pressed():
	hide()


func _on_line_edit_id_text_changed(new_id):
	if selected_node:
		var graph = selected_node.get_parent()
		if graph.get_node_by_id(new_id) or graph.is_option_id_exists(new_id):
			line_edit_id.text = current_panel.id
			return
		
		current_panel.id = new_id
		current_panel.change.emit(current_panel)


func _on_tfh_btn_pressed():
	GlobalSignal.emit("test_trigger", [selected_node.id])


func _on_id_copy_pressed():
	DisplayServer.clipboard_set(current_panel.id)
	var ribbon = ribbon_scene.instantiate()
	ribbon.position = get_viewport().get_mouse_position()
	get_window().add_child(ribbon)
