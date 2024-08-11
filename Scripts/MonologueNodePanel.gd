## Panel control that allows editing of [MonologueGraphNode] values.
class_name MonologueNodePanel
extends VBoxContainer


signal change(panel)

var id
var graph_node: MonologueGraphNode = null : set = _set_gn
var side_panel
var undo_redo: HistoryHandler


func _ready():
	pass


## Load the given graph node data and update this panel's controls to reflect
## that data. Ergo, this method must be called only after this panel is ready.
func _from_dict(_dict: Dictionary):
	pass


func _set_gn(new_gn):
	graph_node = new_gn
	graph_node._connect_to_panel(change)
	undo_redo = graph_node.get_parent().undo_redo


func _on_node_property_change(properties: Array, values: Array) -> bool:
	if undo_redo and values.size() == properties.size():
		var has_changes = false
		# only register undo/redo history if there are actual changes
		for i in values.size():
			if not Util.is_equal(graph_node[properties[i]], values[i]):
				has_changes = true
				break
		
		if has_changes:
			undo_redo.create_action("Update %s data" % graph_node.name)
			
			var change_list: Array[PropertyChange] = []
			for j in values.size():
				var property = properties[j]
				var value = values[j]
				
				var modification = PropertyChange.new(property, graph_node[property], value)
				change_list.append(modification)
			
			var history = PropertyHistory.new(graph_node, change_list)
			undo_redo.add_prepared_history(history)
			undo_redo.commit_action()
			
			return true
	
	return false
