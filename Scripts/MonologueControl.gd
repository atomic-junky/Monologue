extends Control


var dialog = {}
var dialog_for_localisation = []

const HISTORY_FILE_PATH: String = "user://history.save"
const MAX_FILENAME_LENGTH = 48

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

@onready var graph_edit_inst = preload("res://Objects/MonologueGraphEdit.tscn")
@onready var recent_file_button = preload("res://Objects/SubComponents/RecentFileButton.tscn")

@onready var tab_bar: TabBar = $MarginContainer/MainContainer/GraphEditsArea/VBoxContainer/TabBar
@onready var graph_edits: Control = $MarginContainer/MainContainer/GraphEditsArea/VBoxContainer/GraphEdits
@onready var side_panel_node = $MarginContainer/MainContainer/GraphEditsArea/MarginContainer/SidePanelNodeDetails
@onready var saved_notification = $MarginContainer/MainContainer/Header/SavedNotification
@onready var graph_node_selecter = $GraphNodeSelecter
@onready var save_progress_bar: ProgressBar = $MarginContainer/MainContainer/Header/SaveProgressBarContainer/SaveProgressBar
@onready var save_button: Button = $MarginContainer/MainContainer/Header/Save
@onready var test_button: Button = $MarginContainer/MainContainer/Header/TestBtnContainer/Test
@onready var add_menu_bar: PopupMenu = $MarginContainer/MainContainer/Header/MenuBar/Add
@onready var recent_files_container = $WelcomeWindow/PanelContainer/CenterContainer/VBoxContainer2/RecentFilesContainer
@onready var recent_files_button_container = $WelcomeWindow/PanelContainer/CenterContainer/VBoxContainer2/RecentFilesContainer/ButtonContainer
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
	var new_root_node = root_scene.instantiate()
	get_current_graph_edit().add_child(new_root_node)
	connect_side_panel(get_current_graph_edit())
	
	saved_notification.hide()
	save_progress_bar.hide()
	
	# Load recent files
	if not FileAccess.file_exists(HISTORY_FILE_PATH):
		FileAccess.open(HISTORY_FILE_PATH, FileAccess.WRITE)
		recent_files_container.hide()
	else:
		var file = FileAccess.open(HISTORY_FILE_PATH, FileAccess.READ)
		var raw_data = file.get_as_text()
		if raw_data:
			var data: Array = JSON.parse_string(raw_data)
			for path in data:
				if FileAccess.file_exists(path):
					continue
				data.erase(path)
			for path in data.slice(0, 3):
				var btn: Button = recent_file_button.instantiate()
				var btn_text = path.replace("\\", "/")
				btn_text = btn_text.replace("//", "/")
				btn_text = btn_text.split("/")
				if btn_text.size() >= 2:
					btn_text = btn_text.slice(-2, btn_text.size())
					btn_text = btn_text[0].path_join(btn_text[1])
				else:
					btn_text = btn_text.back()
				
				btn.text = truncate_filename(btn_text)
				btn.pressed.connect(file_selected.bind(path, 1))
				recent_files_button_container.add_child(btn)
			recent_files_container.show()
		else:
			recent_files_container.hide()
	
	welcome_window.show()
	no_interactions_dimmer.show()
	
	GlobalSignal.add_listener("add_graph_node", add_node_from_global)
	GlobalSignal.add_listener("test_trigger", test_project)


func _shortcut_input(event):
	if event.is_action_pressed("Save"):
		save(false)
	# IMPORTANT: order matters, redo must come first, undo second
	elif event.is_action_pressed("Redo"):
		get_current_graph_edit().trigger_redo()
	elif event.is_action_pressed("Undo"):
		get_current_graph_edit().trigger_undo()


func _to_dict() -> Dictionary:
	var list_nodes: Array[Dictionary] = []
	var graph_edit = get_current_graph_edit()
	save_progress_bar.max_value = graph_edit.get_children().size() + 1
	
	# compile all node data of the current graph edit
	for node in graph_edit.get_children():
		if node.is_queued_for_deletion():
			continue
		
		# if side panel is still open, release the focus so that some
		# text controls trigger the focus_exited() signal to update
		if side_panel_node.visible and side_panel_node.selected_node == node:
			var refocus = get_viewport().gui_get_focus_owner()
			if refocus:
				refocus.release_focus()
				refocus.grab_focus()
		
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


func connect_side_panel(graph_edit: MonologueGraphEdit) -> void:
	graph_edit.connect("node_selected", side_panel_node.on_graph_node_selected)
	graph_edit.connect("node_deselected", side_panel_node.on_graph_node_deselected)


func get_current_graph_edit() -> MonologueGraphEdit:
	return graph_edits.get_child(tab_bar.current_tab)


func get_root_dict(nodes):
	for node in nodes:
		if node.get("$type") == "NodeRoot":
			return node


func load_project(path):
	if not FileAccess.file_exists(path):
		return
	
	no_interactions_dimmer.hide()
	var graph_edit = get_current_graph_edit()
	
	var file := FileAccess.get_file_as_string(path)
	graph_edit.name = path.get_file().trim_suffix(".json")
	var data := {}
	data = JSON.parse_string(file)

	if not data:
		data = _to_dict()
		save(true)
	
	live_dict = data
	graph_edit.speakers = data.get("Characters")
	graph_edit.variables = data.get("Variables")
	
	for node in graph_edit.get_children():
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
		if not node.has("ID"):
			continue
		
		var current_node = graph_edit.get_node_by_id(node.get("ID"))
		match node.get("$type"):
			"NodeRoot", "NodeSentence", "NodeBridgeOut", "NodeAction", "NodeEvent":
				if node.get("NextID") is String:
					var next_node = graph_edit.get_node_by_id(node.get("NextID"))
					graph_edit.connect_node(current_node.name, 0, next_node.name, 0)
			"NodeChoice":
				current_node._update()
			"NodeDiceRoll":
				if node.get("PassID") is String:
					var pass_node = graph_edit.get_node_by_id(node.get("PassID"))
					graph_edit.connect_node(current_node.name, 0, pass_node.name, 0)
				
				if node.get("FailID") is String:
					var fail_node = graph_edit.get_node_by_id(node.get("FailID"))
					graph_edit.connect_node(current_node.name, 1, fail_node.name, 0)
			"NodeCondition":
				if node.get("IfNextID") is String:
					var if_node = graph_edit.get_node_by_id(node.get("IfNextID"))
					graph_edit.connect_node(current_node.name, 0, if_node.name, 0)
				
				if node.get("ElseNextID") is String:
					var else_node = graph_edit.get_node_by_id(node.get("ElseNextID"))
					graph_edit.connect_node(current_node.name, 1, else_node.name, 0)
		
		if not current_node: # OptionNode
			continue
		
		if node.has("EditorPosition"):
			current_node.position_offset.x = node.EditorPosition.get("x")
			current_node.position_offset.y = node.EditorPosition.get("y")
	
	var root_node = graph_edit.get_node_by_id(root_dict.get("ID"))
	if not root_node:
		var new_root_node = root_scene.instantiate()
		get_current_graph_edit().add_child(new_root_node)
		save(true)


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
	
	var file = FileAccess.open(get_current_graph_edit().file_path, FileAccess.WRITE)
	file.store_string(data)
	file.close()
	
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
	get_current_graph_edit().add_node(node_type)


func test_project(from_node: String = "-1"):
	await save(true)
	
	var global_vars = get_node("/root/GlobalVariables")
	global_vars.test_path = get_current_graph_edit().file_path
	
	var test_instance = preload("res://Test/Menu.tscn")
	var test_scene = test_instance.instantiate()
	
	if get_current_graph_edit().get_node_by_id(from_node) != null:
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
		new_graph_edit()
	
	match file_dialog.file_mode:
		FileDialog.FILE_MODE_SAVE_FILE:
			FileAccess.open(path, FileAccess.WRITE)
			file_selected(path, 0)
		FileDialog.FILE_MODE_OPEN_FILE:
			file_selected(path, 1)


func file_selected(path, open_mode):
	if not FileAccess.open(path, FileAccess.READ):
		return
	
	for ge in graph_edits.get_children():
		if not ge is MonologueGraphEdit:
			continue
		
		if ge.file_path == path:
			return
	
	no_interactions_dimmer.hide()
	
	tab_bar.add_tab(truncate_filename(path.get_file()))
	tab_bar.move_tab(tab_bar.tab_count - 2, tab_bar.tab_count - 1)
	tab_bar.current_tab = tab_bar.tab_count - 2
	
	var graph_edit = get_current_graph_edit()
	graph_edit.control_node = self
	graph_edit.file_path = path
	
	welcome_window.hide()
	if open_mode == 0: #NEW
		for node in graph_edit.get_children():
			node.queue_free()
		var new_root_node = root_scene.instantiate()
		graph_edit.add_child(new_root_node)
		await save(true)

	if not FileAccess.file_exists(HISTORY_FILE_PATH):
		FileAccess.open(HISTORY_FILE_PATH, FileAccess.WRITE)
	else:
		var file: FileAccess = FileAccess.open(HISTORY_FILE_PATH, FileAccess.READ_WRITE)
		var raw_data = file.get_as_text()
		var data: Array
		if raw_data:
			data = JSON.parse_string(raw_data)
			data.erase(path)
			data.insert(0, path)
		else:
			data = [path]
		for p in data:
			if FileAccess.file_exists(p):
				continue
			data.erase(p)
		file = FileAccess.open(HISTORY_FILE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(data.slice(0, 10)))
	
	load_project(path)


## Left-truncate a given filename string based on MAX_FILENAME_LENGTH.
func truncate_filename(filename: String):
	var truncated = filename
	if filename.length() > MAX_FILENAME_LENGTH:
		truncated = "..." + filename.right(MAX_FILENAME_LENGTH - 3)
	return truncated

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
	
	var graph = get_current_graph_edit()
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

###############################
#  Tab-switching and closing  #
###############################

func close_welcome_tab():
	# check number of tabs as safety measure and for future hotkey command
	if tab_bar.tab_count > 1:
		tab_bar.select_previous_available()
		welcome_window.hide()
		no_interactions_dimmer.hide()


func new_graph_edit():
	var graph_edit: MonologueGraphEdit = graph_edit_inst.instantiate()
	var new_root_node = root_scene.instantiate()
	
	graph_edit.name = "new"
	connect_side_panel(graph_edit)
	
	graph_edits.add_child(graph_edit)
	graph_edit.add_child(new_root_node)
	
	for ge in graph_edits.get_children():
		ge.visible = ge == graph_edit


func tab_changed(_idx):
	if tab_bar.get_tab_title(tab_bar.current_tab) != "+":
		for ge in graph_edits.get_children():
			if graph_edits.get_child(tab_bar.current_tab) == ge:
				ge.visible = true
				if ge.graphnode_selected:
					side_panel_node.on_graph_node_selected(ge.active_graphnode, true)
					side_panel_node.show()
				else:
					side_panel_node.hide()
			else:
				ge.visible = false
		return
	
	new_graph_edit()
	var welcome_close_button = $WelcomeWindow/PanelContainer/CloseButton
	if tab_bar.tab_count > 1:
		welcome_close_button.show()
	else:
		welcome_close_button.hide()
	welcome_window.show()
	no_interactions_dimmer.show()
	side_panel_node.hide()


func tab_close_pressed(tab):
	var ge = graph_edits.get_child(tab)
	graph_edits.get_child(tab).queue_free()
	await ge.tree_exited  # buggy if we switch tabs without waiting
	tab_bar.remove_tab(tab)

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
			side_panel_node.show_config()

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
