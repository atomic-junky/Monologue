## Consists of a TabBar which allows the user to switch between GraphEdits.
## Saving and loading of GraphEdit data is handled by MonologueControl.
class_name GraphEditSwitcher extends VBoxContainer


const UNSAVED_FILE_SUFFIX: String = "*"

## Reference to the side panel control to connect graph edits to.
@export var side_panel: SidePanelNodeDetails

var graph_edit_scene = preload("res://Objects/MonologueGraphEdit.tscn")
var prompt_scene = preload("res://Objects/Windows/PromptWindow.tscn")
var root_scene = GlobalVariables.node_dictionary.get("Root")
var current: MonologueGraphEdit: get = get_current_graph_edit
var is_closing_all_tabs: bool

@onready var graph_edits: Control = $GraphEdits
@onready var tab_bar: TabBar = $TabBar


func _ready() -> void:
	current.add_child(root_scene.instantiate())
	connect_side_panel(current)
	GlobalSignal.add_listener("previous_tab", previous_tab)
	GlobalSignal.add_listener("show_current_config", show_current_config)


func _input(event: InputEvent) -> void:
	# IMPORTANT: order matters, redo must come first, undo second
	if event.is_action_pressed("Redo"):
		current.trigger_redo()
	elif event.is_action_pressed("Undo"):
		current.trigger_undo()
	elif event.is_action_pressed("Delete") and not side_panel.visible:
		current.trigger_delete()


## Adds a root node to the current graph edit if given root ID doesn't exist.
func add_root(save: bool = true) -> void:
	if not current.get_root_node():
		var root_node = root_scene.instantiate()
		current.add_child(root_node)
		if save: GlobalSignal.emit("save", [true])


## Adds a new tab with the given JSON filename as the tab title.
func add_tab(filename: String) -> void:
	tab_bar.add_tab(Util.truncate_filename(filename))
	tab_bar.move_tab(tab_bar.tab_count - 2, tab_bar.tab_count - 1)
	tab_bar.current_tab = tab_bar.tab_count - 2


func connect_side_panel(graph_edit: MonologueGraphEdit) -> void:
	graph_edit.connect("node_selected", side_panel.on_graph_node_selected)
	graph_edit.connect("node_deselected", side_panel.on_graph_node_deselected)
	graph_edit.undo_redo.connect("version_changed", update_save_state)


func commit_side_panel(node: MonologueGraphNode) -> void:
	side_panel.refocus(node)


func get_current_graph_edit() -> MonologueGraphEdit:
	return graph_edits.get_child(tab_bar.current_tab)


## Check if a graph edit representing the given filepath is opened or not.
func is_file_opened(filepath: String) -> bool:
	for node in graph_edits.get_children():
		if node is MonologueGraphEdit and node.file_path == filepath:
			return true
	return false


func new_graph_edit() -> void:
	var graph_edit = graph_edit_scene.instantiate()
	var root_node = root_scene.instantiate()
	
	graph_edit.name = "new"
	graph_edit.add_child(root_node)
	connect_side_panel(graph_edit)
	graph_edits.add_child(graph_edit)
	
	for ge in graph_edits.get_children():
		ge.visible = ge == graph_edit


func on_tab_close_pressed(tab: int) -> void:
	var ge = graph_edits.get_child(tab)
	if ge.is_unsaved():  # prompt user if there are unsaved changes
		GlobalSignal.emit("disable_picker_mode")
		tab_bar.current_tab = tab
		var save_prompt = prompt_scene.instantiate()
		save_prompt.connect("confirmed", _close_tab.bind(ge, tab, true))
		save_prompt.connect("cancelled", set.bind("is_closing_all_tabs", false))
		save_prompt.connect("denied", _close_tab.bind(ge, tab))
		add_child(save_prompt)
		save_prompt.prompt_save(ge.file_path)
	else:
		_close_tab(ge, tab)


func previous_tab():
	if tab_bar.tab_count > 1:
		tab_bar.select_previous_available()


## Select the RootNode of the current graph edit, which opens the side panel.
func show_current_config() -> void:
	var root_node = current.get_root_node()
	current.set_selected(root_node)


## Update tab title with a suffix based on the current graph_edit's save state.
func update_save_state() -> void:
	var index = current.get_index()
	var trim = tab_bar.get_tab_title(index).trim_suffix(UNSAVED_FILE_SUFFIX)
	var title = trim + UNSAVED_FILE_SUFFIX if current.is_unsaved() else trim
	tab_bar.set_tab_title(index, title)


func _close_tab(graph_edit, tab_index, save_first = false) -> void:
	if save_first:
		GlobalSignal.emit("save", [true])
	graph_edit.queue_free()
	await graph_edit.tree_exited  # buggy if we switch tabs without waiting
	tab_bar.remove_tab(tab_index)
	
	if tab_bar.tab_count == 0:
		get_tree().quit()
	elif is_closing_all_tabs:
		on_tab_close_pressed(0)


func _on_tab_changed(tab: int) -> void:
	if tab_bar.get_tab_title(tab) != "+":
		for ge in graph_edits.get_children():
			if graph_edits.get_child(tab) == ge:
				ge.visible = true
				if ge.active_graphnode:
					side_panel.on_graph_node_selected(ge.active_graphnode, true)
				else:
					side_panel.hide()
			else:
				ge.visible = false
		return
	
	new_graph_edit()
	GlobalSignal.emit("show_welcome", [tab_bar.tab_count > 1])
	side_panel.hide()
