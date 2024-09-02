## Panel control that allows editing of [MonologueGraphNode] values.
class_name MonologueNodePanel extends VBoxContainer


signal change(panel)

var id
var id_line_edit: LineEdit
var graph_node: MonologueGraphNode = null : set = _set_graph_node
var side_panel
var undo_redo: HistoryHandler

var speakers: Array :
	get():
		return get_graph_edit_property("speakers")
var variables: Array :
	get():
		return get_graph_edit_property("variables")

var fields: Dictionary = {}


func _ready():
	_load()
	add_theme_constant_override("separation", 10)


func get_graph_edit_property(property: StringName) -> Variant:
	return graph_node.get_parent().get(property)


func _load_fields(dict: Dictionary = {}) -> void:
	var groups: Array = graph_node.get_fields()
	
	for group in groups:
		_load_field_group(group, dict)


func _load_field_group(group: Dictionary, dict: Dictionary) -> void:
	var vbox := VBoxContainer.new()
	
	for field in group.keys():
		var node: MonologueField = group[field]
		vbox.add_child(node)
		node.field_update.connect(_on_field_update.bindv([field]))
		node.set_value(dict.get(field))
	
	add_child(vbox)


func _load():
	pass


## Load the given graph node data and update this panel's controls to reflect
## that data. Ergo, this method must be called only after this panel is ready.
func _from_dict(dict: Dictionary):
	# Load and bind ID
	id_line_edit.connect("text_changed", _on_field_update.bindv(["ID"]))
	fields["ID"] = dict.get("ID", "")
	id_line_edit.text = fields["ID"]
	
	_load_fields(dict)


func _set_graph_node(new_graph_node: MonologueGraphNode) -> void:
	graph_node = new_graph_node
	undo_redo = graph_node.get_parent().undo_redo


func _on_field_update(value: Variant, field: String) -> void:
	fields[field] = value
	graph_node._update_fields(fields)


## @deprecated
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
