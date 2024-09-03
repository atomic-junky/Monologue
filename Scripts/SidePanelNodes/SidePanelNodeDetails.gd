class_name SidePanelNodeDetails
extends PanelContainer


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

@onready var control_node = $"../../../../../../.."
@onready var line_edit_id = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer/LineEditID
@onready var panel_container = $MarginContainer/ScrollContainer/PanelContainer
@onready var ribbon_scene = preload("res://Objects/SubComponents/Ribbon.tscn")

var current_panel: MonologueNodePanel = null
var selected_node: MonologueGraphNode = null


func _ready():
	hide()


func clear_current_panel():
	if current_panel:
		current_panel.queue_free()
		current_panel = null


func on_graph_node_selected(node: MonologueGraphNode, bypass: bool = false):
	if not bypass:
		var graph_edit = control_node.get_current_graph_edit()
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(node) and not graph_edit.moving_mode and \
				graph_edit.selected_nodes.size() == 1:
			graph_edit.active_graphnode = node
		else:
			graph_edit.active_graphnode = null
			return
	
	line_edit_id.text = node.id
	var new_panel = null
	var panel_scene = panel_dictionary.get(node.node_type)
	
	if not panel_scene:
		return
	
	clear_current_panel()
	new_panel = panel_scene.instantiate()
	new_panel.side_panel = self
	new_panel.graph_node = node
	current_panel = new_panel
	selected_node = node
	panel_container.add_child(new_panel)
	new_panel._from_dict(node._to_dict())
	# this is for undo/redo to propagate gui updates back to its graph node
	node._update(new_panel)
	
	show()


func show_config():
	var graph_edit = control_node.get_current_graph_edit()
	var root_node = graph_edit.get_root_node()
	graph_edit.set_selected(root_node)


func _on_graph_edit_child_exiting_tree(_node):
	hide()


func on_graph_node_deselected(_node):
	hide()


func _on_texture_button_pressed():
	hide()


func _on_line_edit_id_text_changed(new_id):
	var graph = control_node.get_current_graph_edit()
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
	control_node.add_child(ribbon)
