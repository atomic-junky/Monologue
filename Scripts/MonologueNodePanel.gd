class_name MonologueNodePanel
extends VBoxContainer


signal change(panel)

var id
var graph_node: MonologueGraphNode = null : set = _set_gn
var side_panel
var undo_redo: HistoryHandler


func _ready():
	pass


func _from_dict(_dict: Dictionary):
	pass


func _set_gn(new_gn):
	graph_node = new_gn
	graph_node._connect_to_panel(change)
	undo_redo = graph_node.get_parent().undo_redo


func _on_node_property_change(value, property, refresh = false) -> bool:
	# just a direct equality comparison, not an iterative/deep comparison
	if undo_redo and graph_node[property] != value:
		var message = "Update %s %s to %s"
		undo_redo.create_action(message % [graph_node.name, property, value])
		
		var change_list: Array[PropertyChange] = [
			PropertyChange.new(property, graph_node[property], value)]
			
		var history = PropertyHistory.new(graph_node, change_list, refresh)
		undo_redo.add_prepared_history(history)
		undo_redo.commit_action()
		return true
		
	return false
