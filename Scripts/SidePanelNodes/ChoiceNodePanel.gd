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


## Retrives a given option node by ID from [member options_container].
func get_option_node(option_id: String):
	for node in options_container.get_children():
		if node.id == option_id:
			return node


## Creates a new option. If given a [param from_copy], its data will be
## applied to the newly created option node.
func new_option(from_copy: Dictionary = {}) -> OptionNode:
	var option = option_panel.instantiate()
	option.panel_node = self
	option.graph_node = graph_node
	options_container.add_child(option)
	
	# restore data AFTER add_child(), the UI needs to be ready to update!
	if not from_copy.is_empty():
		option._from_dict(from_copy)
	
	option.update_ref()
	return option


func _on_add_option_pressed():
	var created_option = new_option()
	
	var undo_redo: HistoryHandler = graph_node.get_parent().undo_redo
	undo_redo.create_action("Add new option to %s" % graph_node.id)
	var option_history = AddOptionHistory.new(graph_node, created_option)
	undo_redo.add_prepared_history(option_history)
	undo_redo.commit_action(false)
