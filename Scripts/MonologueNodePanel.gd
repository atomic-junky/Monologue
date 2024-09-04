## Panel control that allows editing of [MonologueGraphNode] values.
class_name MonologueNodePanel extends VBoxContainer


var fields: Dictionary = {}
var graph_node: MonologueGraphNode : set = _set_graph_node
var undo_redo: HistoryHandler


func _ready():
	add_theme_constant_override("separation", 10)


## Refresh the field UI for the given field key and value.
func set_field_values(change_list: Array[PropertyChange], is_after: bool):
	for change in change_list:
		var field = fields.get(change.property)
		if field:
			field.value = change.after if is_after else change.before


func _set_graph_node(new_graph_node: MonologueGraphNode) -> void:
	graph_node = new_graph_node
	undo_redo = graph_node.get_parent().undo_redo
	
	for field in graph_node.get_fields():
		fields[field.property] = field
		field.node_panel = self
		add_child(field)


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
