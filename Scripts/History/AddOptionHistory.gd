## Defines the undo/redo pair for adding a new option in [ChoiceNode].
class_name AddOptionHistory
extends MonologueHistory

## Monologue node panels are instantiated on selection. What if the user
## tries to undo an option creation, but does not have the side panel open?
## So we have to create a panel in the background to update the options.
## But what if the panel is already open? Then we need to update that panel.
var panel_scene = preload("res://Objects/SidePanelNodes/ChoiceNodePanel.tscn")

## Stored choice node name, for when options needs its owner.
## Node names are tracked, courtesy of [AddNodeHistory].
var choice_node_name: String
## Reference to the graph edit that these options are in.
var graph_edit: MonologueGraphEdit
## Stored option data to be restored.
var option_data: Dictionary

## If true, destroy the ChoiceNodePanel of the option after undo/redo.
var _destroy_panel: bool = false


func _init(choice_node: ChoiceNode, option_node: OptionNode):
	choice_node_name = choice_node.name
	graph_edit = choice_node.get_parent()
	option_data = option_node._to_dict()
	
	_undo_callback = delete_option
	_redo_callback = restore_data


func get_choice_panel() -> ChoiceNodePanel:
	var choice_node = graph_edit.get_node(choice_node_name)
	var current_panel = graph_edit.control_node.side_panel_node.current_panel
	if current_panel.graph_node == choice_node:
		# check if current side panel is a ChoiceNodePanel that is linked to
		# the ChoiceNode that owns these tracked options
		_destroy_panel = false
		return current_panel
	else:
		# otherwise, create a hidden panel to manipulate the options
		var choice_panel: ChoiceNodePanel = panel_scene.instantiate()
		choice_panel.graph_node = choice_node
		choice_panel.hide()
		graph_edit.add_child(choice_panel)
		choice_panel._from_dict(choice_node._to_dict())
		_destroy_panel = true
		return choice_panel


func delete_panel(panel: ChoiceNodePanel):
	if _destroy_panel:
		panel.queue_free()


func delete_option():
	var choice_panel = get_choice_panel()
	# this will fail if there is an untracked change in option ID
	# thankfully, the ID should be reverted to its saved state before deletion
	var option = choice_panel.get_option_node(option_data.get("ID"))
	# update data before delete
	option_data = option._to_dict()
	option.delete()
	delete_panel(choice_panel)


func restore_data():
	var choice_panel = get_choice_panel()
	choice_panel.new_option(option_data)
	# option connections are automatically handled by ChoiceNode _update()
	delete_panel(choice_panel)
