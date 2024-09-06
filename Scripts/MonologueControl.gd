class_name MonologueControl extends Control


var dialog = {}
var dialog_for_localisation = []

@onready var dimmer: ColorRect = $NoInteractions
@onready var graph: GraphEditSwitcher = %GraphEditSwitcher
@onready var header: Header = %Header
@onready var welcome: WelcomeWindow = $WelcomeWindow


func _ready():
	get_tree().auto_accept_quit = false  # quit handled by _close_tab()
	welcome.open()
	
	GlobalSignal.add_listener("add_graph_node", add_node_from_global)
	GlobalSignal.add_listener("show_dimmer", dimmer.show)
	GlobalSignal.add_listener("hide_dimmer", dimmer.hide)
	GlobalSignal.add_listener("load_project", load_project)
	GlobalSignal.add_listener("test_trigger", test_project)
	GlobalSignal.add_listener("save", save)


func _shortcut_input(event):
	if event.is_action_pressed("Save"):
		save(false)


func _to_dict() -> Dictionary:
	var list_nodes: Array[Dictionary] = []
	header.start_save_progress(graph.current.get_nodes().size() + 1)
	
	# compile all node data of the current graph edit
	for node in graph.current.get_nodes():
		if not node.is_queued_for_deletion():
			graph.commit_side_panel(node)
			list_nodes.append(node._to_dict())
			if node.node_type == "NodeChoice":
				for child in node.get_children():
					list_nodes.append(child._to_dict())
		header.increment_save_progress()
	
	# build data for dialogue speakers
	var characters = graph.current.speakers
	if characters.size() <= 0:
		characters.append({
			"Reference": "_NARRATOR",
			"ID": 0
		})
	header.increment_save_progress()
	
	return {
		"EditorVersion": ProjectSettings.get_setting("application/config/version", "unknown"),
		"RootNodeID": get_root_dict(list_nodes).get("ID"),
		"ListNodes": list_nodes,
		"Characters": characters,
		"Variables": graph.current.variables
	}


## Function callback for when the user wants to add a node from global context.
## Used by header menu and graph node selector (picker).
func add_node_from_global(node_type: String, picker: GraphNodeSelector = null):
	graph.current.add_node(node_type, true, picker)


func get_root_dict(node_list: Array) -> Dictionary:
	for node in node_list:
		if node.get("$type") == "NodeRoot":
			return node
	return {}


func load_project(path: String, new_graph: bool = false) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file and not graph.is_file_opened(path):
		if new_graph: graph.new_graph_edit()
		graph.add_tab(path.get_file())
		graph.current.file_path = path
		welcome.add_recent_file(path)
		welcome.close()
		
		var data = {}
		var text = file.get_as_text()
		if text: data = JSON.parse_string(text)
		if not data:
			data = _to_dict()
			save(true)
		
		graph.current.clear()
		graph.current.name = path.get_file().trim_suffix(".json")
		graph.current.speakers = data.get("Characters")
		graph.current.variables = data.get("Variables")
		graph.current.data = data
		
		var node_list = data.get("ListNodes")
		_load_nodes(node_list)
		_connect_nodes(node_list)
		graph.add_root()
		graph.current.update_node_positions()


func save(quick: bool = false):
	var data = JSON.stringify(_to_dict(), "\t", false, true)
	if data:
		var path = graph.current.file_path
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(data)
		file.close()
		graph.current.update_version()
		graph.update_save_state()
		header.show_save_notification(0.0 if quick else 1.5)
	else:
		header.hide_save_notification()  # fail to load


func test_project(from_node: String = "-1"):
	await save(true)
	GlobalVariables.test_path = graph.current.file_path
	var test_scene = preload("res://Test/Menu.tscn")
	var test_instance = test_scene.instantiate()
	
	if graph.current.get_node_by_id(from_node) != null:
		test_instance._from_node_id = from_node
	
	get_tree().root.add_child(test_instance)


func _connect_nodes(node_list: Array) -> void:
	for node in node_list:
		var current_node = graph.current.get_node_by_id(node.get("ID", ""))
		if current_node:
			current_node._load_connections(node)


func _load_nodes(node_list: Array) -> void:
	var converter = NodeConverter.new()
	for node in node_list:
		var data = converter.convert_node(node)
		var node_type = data.get("$type").trim_prefix("Node")
		var node_scene = GlobalVariables.node_dictionary.get(node_type)
		if node_scene:
			var node_instance = node_scene.instantiate()
			node_instance.id = data.get("ID")
			graph.current.add_child(node_instance, true)
			node_instance._from_dict(data)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_viewport().gui_release_focus()
		graph.is_closing_all_tabs = true
		graph.on_tab_close_pressed(0)
