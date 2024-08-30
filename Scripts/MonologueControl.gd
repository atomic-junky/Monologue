extends Control


var dialog = {}
var dialog_for_localisation = []

## Dictionary of Monologue node types and their corresponding scenes.
var scene_dictionary = {
	"Root": preload("res://Objects/GraphNodes/RootNode.tscn"),
	"Action": preload("res://Objects/GraphNodes/ActionNode.tscn"),
	"Bridge": preload("res://Objects/GraphNodes/BridgeInNode.tscn"),
	"BridgeIn": preload("res://Objects/GraphNodes/BridgeInNode.tscn"),
	"BridgeOut": preload("res://Objects/GraphNodes/BridgeOutNode.tscn"),
	"Choice": preload("res://Objects/GraphNodes/ChoiceNode.tscn"),
	"Comment": preload("res://Objects/GraphNodes/CommentNode.tscn"),
	"Condition": preload("res://Objects/GraphNodes/ConditionNode.tscn"),
	"DiceRoll": preload("res://Objects/GraphNodes/DiceRollNode.tscn"),
	"EndPath": preload("res://Objects/GraphNodes/EndPathNode.tscn"),
	"Event": preload("res://Objects/GraphNodes/EventNode.tscn"),
	"Sentence": preload("res://Objects/GraphNodes/SentenceNode.tscn"),
}

@onready var prompt_scene = preload("res://Objects/Windows/PromptWindow.tscn")

@onready var side_panel_node = $MarginContainer/MainContainer/GraphEditsArea/MarginContainer/SidePanelNodeDetails
@onready var saved_notification = $MarginContainer/MainContainer/Header/SavedNotification
@onready var graph_switcher = %GraphEditSwitcher
@onready var graph_node_selecter = $GraphNodeSelecter
@onready var save_progress_bar: ProgressBar = $MarginContainer/MainContainer/Header/SaveProgressBarContainer/SaveProgressBar
@onready var save_button: Button = $MarginContainer/MainContainer/Header/Save
@onready var test_button: Button = $MarginContainer/MainContainer/Header/TestBtnContainer/Test
@onready var add_menu_bar: PopupMenu = $MarginContainer/MainContainer/Header/MenuBar/Add
@onready var file_dialog = $FileDialog
@onready var no_interactions_dimmer = $NoInteractions
@onready var welcome_window = $WelcomeWindow

var root_scene = scene_dictionary.get("Root")
var live_dict: Dictionary

## Set to true if a file operation is triggered from Header instead of WelcomeWindow.
var is_header_file_operation: bool = false

var initial_pos = Vector2(40,40)
var option_index = 0
var node_index = 0
var all_nodes_index = 0

var picker_mode: bool = false
var picker_from_node
var picker_from_port
var picker_position


func _ready():
	get_tree().auto_accept_quit = false  # quit handled by _close_tab()
	
	saved_notification.hide()
	save_progress_bar.hide()
	
	welcome_window.show()
	no_interactions_dimmer.show()
	
	GlobalSignal.add_listener("add_graph_node", add_node_from_global)
	GlobalSignal.add_listener("disable_picker_mode", disable_picker_mode)
	GlobalSignal.add_listener("test_trigger", test_project)
	GlobalSignal.add_listener("save", save)


func _shortcut_input(event):
	if event.is_action_pressed("Save"):
		save(false)
	# IMPORTANT: order matters, redo must come first, undo second
	elif event.is_action_pressed("Redo"):
		graph_switcher.current.trigger_redo()
	elif event.is_action_pressed("Undo"):
		graph_switcher.current.trigger_undo()


func _to_dict() -> Dictionary:
	var list_nodes: Array[Dictionary] = []
	var graph_edit = graph_switcher.current
	save_progress_bar.max_value = graph_edit.get_nodes().size() + 1
	
	# compile all node data of the current graph edit
	for node in graph_edit.get_nodes():
		if node.is_queued_for_deletion():
			continue
		
		graph_switcher.commit_side_panel(node)
		list_nodes.append(node._to_dict())
		if node.node_type == "NodeChoice":
			for child in node.get_children():
				list_nodes.append(child._to_dict())
		
		save_progress_bar.value = list_nodes.size()
	
	# build data for dialogue speakers
	var characters = graph_edit.speakers
	if graph_edit.speakers.size() <= 0:
		characters.append({
			"Reference": "_NARRATOR",
			"ID": 0
		})
	save_progress_bar.value += 1
	
	return {
		"EditorVersion": ProjectSettings.get_setting("application/config/version", "unknown"),
		"RootNodeID": get_root_dict(list_nodes).get("ID"),
		"ListNodes": list_nodes,
		"Characters": characters,
		"Variables": graph_edit.variables
	}


func get_root_dict(nodes):
	for node in nodes:
		if node.get("$type") == "NodeRoot":
			return node


func file_selected(path, open_mode):
	var openable = FileAccess.open(path, FileAccess.READ)
	if not openable or graph_switcher.is_file_opened(path):
		return
	openable.close()
	
	no_interactions_dimmer.hide()
	graph_switcher.add_tab(path.get_file())
	var graph_edit = graph_switcher.current
	graph_edit.control_node = self
	graph_edit.file_path = path
	graph_edit.undo_redo.connect("version_changed", graph_switcher.update_save_state)
	
	welcome_window.hide()
	if open_mode == 0: #NEW
		for node in graph_edit.get_nodes():
			node.queue_free()
		var new_root_node = root_scene.instantiate()
		graph_edit.add_child(new_root_node)
		await save(true)

	%RecentFilesContainer.add(path)
	
	load_project(path)


func load_project(path):
	if not FileAccess.file_exists(path):
		return
	no_interactions_dimmer.hide()
	
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data:
		data = _to_dict()
		save(true)
	
	live_dict = data
	var graph_edit = graph_switcher.current
	graph_edit.name = path.get_file().trim_suffix(".json")
	graph_edit.speakers = data.get("Characters")
	graph_edit.variables = data.get("Variables")
	
	for node in graph_edit.get_nodes():
		node.queue_free()
	graph_edit.clear_connections()
	graph_edit.data = data
	
	var node_list = data.get("ListNodes")
	var root_dict = get_root_dict(node_list)
	
	# create nodes from JSON data
	for node in node_list:
		var node_type: String = node.get("$type")
		var node_scene = scene_dictionary.get(node_type.trim_prefix("Node"))
		if not node_scene:
			continue
		
		var new_node = node_scene.instantiate()
		new_node.id = node.get("ID")
		graph_edit.add_child(new_node, true)
		new_node._from_dict(node)
	
	# load connections for the created nodes
	for node in node_list:
		var current_node = graph_edit.get_node_by_id(node.get("ID", ""))
		if current_node:
			current_node._load_connections(node)
		if node.has("EditorPosition"):
			current_node.position_offset.x = node.EditorPosition.get("x")
			current_node.position_offset.y = node.EditorPosition.get("y")
	
	var root_node = graph_edit.get_node_by_id(root_dict.get("ID"))
	if not root_node:
		var new_root_node = root_scene.instantiate()
		graph_edit.add_child(new_root_node)
		save(true)
	graph_edit.update_node_positions()


func save(quick: bool = false):
	save_progress_bar.value = 0
	save_progress_bar.show()
	save_button.hide()
	test_button.hide()
	
	var data = JSON.stringify(_to_dict(), "\t", false, true)
	if not data: # Fail to load 
		save_progress_bar.hide()
		save_button.show()
		test_button.show()
	
	var path = graph_switcher.current.file_path
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)
	file.close()
	graph_switcher.update_save_state()
	
	saved_notification.show()
	if !quick:
		await get_tree().create_timer(1.5).timeout
	saved_notification.hide()
	save_progress_bar.hide()
	save_button.show()
	test_button.show()

###############################
#  New node buttons callback  #
###############################

func _on_add_id_pressed(id):
	var node_type = add_menu_bar.get_item_text(id)
	GlobalSignal.emit("add_graph_node", [node_type])


## Function callback for when the user wants to add a node from global context.
## Used by header menu and graph node selector (picker).
func add_node_from_global(node_type):
	graph_switcher.current.add_node(node_type)


func test_project(from_node: String = "-1"):
	await save(true)
	
	var global_vars = get_node("/root/GlobalVariables")
	global_vars.test_path = graph_switcher.current.file_path
	
	var test_instance = preload("res://Test/Menu.tscn")
	var test_scene = test_instance.instantiate()
	
	if graph_switcher.current.get_node_by_id(from_node) != null:
		test_scene._from_node_id = from_node
	
	get_tree().root.add_child(test_scene)

####################
#  File selection  #
####################

func new_file_select():
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.title = "Create New File"
	file_dialog.ok_button_text = "Create"
	file_dialog.popup_centered()


func open_file_select():
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.title = "Open File"
	file_dialog.ok_button_text = "Open"
	file_dialog.popup_centered()


func _on_file_dialog_selected(path: String):
	if is_header_file_operation:
		welcome_window.hide()
		file_dialog.hide()
		graph_switcher.new_graph_edit()
	
	match file_dialog.file_mode:
		FileDialog.FILE_MODE_SAVE_FILE:
			FileAccess.open(path, FileAccess.WRITE)
			file_selected(path, 0)
		FileDialog.FILE_MODE_OPEN_FILE:
			file_selected(path, 1)

##################################
#  Graph node selecter (picker)  #
##################################

## Start the picker mode from a given node and port. Picker mode is where
## a new node is created from another node through a connection to empty.
func enable_picker_mode(from_node, from_port, _release_position):
	graph_node_selecter.position = get_viewport().get_mouse_position()
	graph_node_selecter.show()
	picker_from_node = from_node
	picker_from_port = from_port
	
	var graph = graph_switcher.current
	picker_position = (graph.get_local_mouse_position() + graph.scroll_offset) / graph.zoom
	picker_mode = true
	no_interactions_dimmer.show()


## Exit picker mode. Picker mode is where a new node is created from another
## node through a connection to empty.
func disable_picker_mode():
	graph_node_selecter.hide()
	picker_mode = false
	no_interactions_dimmer.hide()


func _on_graph_node_selecter_focus_exited():
	disable_picker_mode()


func _on_graph_node_selecter_close_requested():
	disable_picker_mode()

#################
#  Header menu  #
#################

func _on_file_id_pressed(id):
	match id:
		0: # Open file
			is_header_file_operation = true
			open_file_select()

		1: # New file
			is_header_file_operation = true
			new_file_select()

		3: # Config
			graph_switcher.show_current_config()

		4: # Test
			GlobalSignal.emit("test_trigger")


func _on_new_file_btn_pressed():
	is_header_file_operation = false
	new_file_select()


func _on_open_file_btn_pressed():
	is_header_file_operation = false
	open_file_select()


func _on_help_id_pressed(id):
	match id:
		0:
			OS.shell_open("https://github.com/atomic-junky/Monologue/wiki")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_viewport().gui_release_focus()
		graph_switcher.is_closing_all_tabs = true
		graph_switcher.on_tab_close_pressed(0)
