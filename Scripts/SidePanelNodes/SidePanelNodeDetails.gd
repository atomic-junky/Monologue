extends PanelContainer


@onready var line_edit_id = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer/LineEditID
@onready var panel_container = $MarginContainer/ScrollContainer/PanelContainer
@onready var control_node = $"../../../../.."

@onready var root_node_panel_instance = preload("res://Objects/SidePanelNodes/RootNodePanel.tscn")
@onready var sentence_node_panel_instance = preload("res://Objects/SidePanelNodes/SentenceNodePanel.tscn")
@onready var choice_node_panel_instance = preload("res://Objects/SidePanelNodes/ChoiceNodePanel.tscn")
@onready var dice_roll_node_panel_instance = preload("res://Objects/SidePanelNodes/DiceRollNodePanel.tscn")
@onready var end_path_node_panel_instance = preload("res://Objects/SidePanelNodes/EndPathNodePanel.tscn")
@onready var condition_node_panel_instance = preload("res://Objects/SidePanelNodes/ConditionNodePanel.tscn")
@onready var action_node_panel_instance = preload("res://Objects/SidePanelNodes/ActionNodePanel.tscn")

var selected_node = null
var current_panel = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func clear_current_panel():
	if current_panel:
		current_panel.queue_free()
		current_panel = null


func on_graph_node_selected(node):
	var graph_edit = control_node.get_current_graph_edit()
	await get_tree().create_timer(0.1).timeout
	if graph_edit.selection_mode or graph_edit.moving_mode:
		return
		
	line_edit_id.text = node.id

	var new_panel = null
	match node.node_type:
		"NodeRoot":
			new_panel = root_node_panel_instance.instantiate()
		"NodeSentence":
			new_panel = sentence_node_panel_instance.instantiate()
		"NodeChoice":
			new_panel = choice_node_panel_instance.instantiate()
		"NodeDiceRoll":
			new_panel = dice_roll_node_panel_instance.instantiate()
		"NodeEndPath":
			new_panel = end_path_node_panel_instance.instantiate()
		"NodeCondition":
			new_panel = condition_node_panel_instance.instantiate()
		"NodeAction":
			new_panel = action_node_panel_instance.instantiate()
		"NodeEvent":
			new_panel = condition_node_panel_instance.instantiate()
	
	if new_panel == null:
		return
	
	clear_current_panel()
	
	new_panel.graph_node = node
	
	if new_panel:
		current_panel = new_panel
		selected_node = node
		panel_container.add_child(new_panel)
		new_panel._from_dict(node._to_dict())
		
	show()


func _on_texture_button_pressed():
	hide()


func show_config():
	clear_current_panel()
	
	var root_node = control_node.root_node_ref
	
	root_node.selected = true

	var new_panel = root_node_panel_instance.instantiate()
	new_panel.graph_node = root_node
	current_panel = new_panel
	
	panel_container.add_child(new_panel)
	new_panel._from_dict(root_node._to_dict())
	
	line_edit_id.text = root_node.id
	
	show()


func _on_graph_edit_child_exiting_tree(_node):
	hide()


func on_graph_node_deselected(_node):
	hide()


func _on_line_edit_id_text_changed(new_id):
	if control_node.get_node_by_id(new_id):
		line_edit_id.text = current_panel.id
		return
	
	current_panel.id = new_id
	current_panel.change.emit(current_panel)


func _on_tfh_btn_pressed():
	GlobalSignal.emit("test_trigger", [selected_node.id])


func _on_id_copy_pressed():
	DisplayServer.clipboard_set(current_panel.id)
