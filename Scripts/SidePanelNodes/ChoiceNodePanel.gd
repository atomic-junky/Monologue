@icon("res://Assets/Icons/NodesIcons/Multiple Choice.svg")

class_name ChoiceNodePanel
extends MonologueNodePanel


const arrow_texture01 = preload("res://Assets/Icons/NodesIcons/Arrow01.svg")
const arrow_texture02 = preload("res://Assets/Icons/NodesIcons/Arrow02.svg")

@onready var option_panel = preload("res://Objects/SubComponents/OptionNode.tscn")
@onready var options_container = $OptionsContainer


## This creates options from [method ChoiceNode._to_dict].
func _from_dict(dict):
	id = dict.get("ID")
	
	for option in graph_node.options:
		var opt_panel = option_panel.instantiate()
		opt_panel.panel_node = self
		opt_panel.graph_node = graph_node
		
		options_container.add_child(opt_panel)
		opt_panel._from_dict(option)
	
	change.emit(self)


## Disconnects all option graph connections. Used to refresh the UI.
func disconnect_all_option_links():
	for option in options_container.get_children():
		graph_node.link_option(
				graph_node.find_option_dictionary(option.id), false)


## Gets the panel information of all options in [member options_container].
func get_panel_option_data():
	var data = []
	for option in options_container.get_children():
		if not option.is_queued_for_deletion():
			data.append(option._to_dict())
	return data


## Retrives a given option node by ID from [member options_container].
func get_option_node(option_id: String):
	for node in options_container.get_children():
		if node.id == option_id:
			return node


## Creates a new option. If given a [param from_copy], its data will be
## applied to the newly created option node.
func new_option(from_copy: Dictionary = {}, index: int = -1) -> OptionNode:
	var option = option_panel.instantiate()
	option.panel_node = self
	option.graph_node = graph_node
	options_container.add_child(option)
	
	if index >= 0:
		options_container.move_child(option, index)
	
	# restore data AFTER add_child(), the UI needs to be ready to update!
	if not from_copy.is_empty():
		option._from_dict(from_copy)
	
	option.update_ref()
	return option


## Adds latest option data changes into graph history, if any.
func register_option_changes(note: String = "option data"):
	var panel_options = get_panel_option_data()
	if panel_options.hash() != graph_node.options.hash():
		var message = "Update %s for %s (id: %s)"
		var undo_redo = graph_node.get_parent().undo_redo
		undo_redo.create_action(message % [note, graph_node.node_type, id])
		var changes: Array[PropertyChange] = [
			PropertyChange.new("options", graph_node.options, panel_options)
		]
		var option_change = PropertyHistory.new(graph_node, changes)
		undo_redo.add_prepared_history(option_change)
		undo_redo.commit_action(false)


func _on_add_option_pressed():
	var created_option = new_option()
	
	var undo_redo: HistoryHandler = graph_node.get_parent().undo_redo
	undo_redo.create_action("Add new option to %s" % graph_node.id)
	var option_history = AddOptionHistory.new(graph_node, created_option)
	undo_redo.add_prepared_history(option_history)
	undo_redo.commit_action(false)
