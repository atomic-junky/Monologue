class_name MonologueNodePanel
extends VBoxContainer


signal change(panel)

var id
var graph_node: MonologueGraphNode = null : set = _set_gn

## Reference to the Monologue side panel control.
var side_panel
## Reference to the UndoRedo history handler.
var undo_redo: HistoryHandler


func _ready():
	pass


func _from_dict(_dict: Dictionary):
	pass


func _set_gn(new_gn):
	graph_node = new_gn
	graph_node._connect_to_panel(change)
	undo_redo = graph_node.get_parent().undo_redo


## Callback for any basic node data changes via its node panel controls.
## Returns true if history was committed successfully.
func _on_node_property_change(value: Variant, property: String):
	if undo_redo and graph_node[property] != value:
		var message = "Update %s %s to %s"
		undo_redo.create_action(message % [graph_node.name, property, value])
		
		var change_list: Array[PropertyChange] = [
			PropertyChange.new(property, graph_node[property], value)]
		var history = PropertyHistory.new(graph_node, change_list, false)
		undo_redo.add_prepared_history(history)
		
		undo_redo.commit_action()
		return true
		
	return false
