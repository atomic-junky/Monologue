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


func get_graph_edit_property(property: StringName) -> Variant:
	return graph_node.get_parent().get(property)


func _load_fields(base: Node = self, dict: Dictionary = {}):
	for child: Node in base.get_children():
		if child.name.begins_with("Field_"):
			var field_name = child.name.trim_prefix("Field_")
			
			if child is FilePickerLineEdit:
				child.base_file_path = graph_node.get_parent().file_path
				child.connect("new_file_path", _on_file_picker_line_edit_update.bindv([field_name]))
				fields[field_name] = dict.get(field_name, "")
				child.text = fields[field_name]
			elif child is LineEdit:
				child.connect("text_changed", _on_field_update.bindv([field_name]))
				fields[field_name] = dict.get(field_name, "")
				child.text = fields[field_name]
			elif child is TextEdit:
				child.connect("text_changed", _on_te_field_update.bindv([child, field_name]))
				fields[field_name] = dict.get(field_name, "")
				child.text = fields[field_name]
			elif child is MonologueOptionButton:
				child.connect("item_selected", _on_option_button_field_update.bindv([child, field_name]))
				fields[field_name] = dict.get(field_name, "_NARRATOR")
				child.select(child.get_item_idx_from_text(fields[field_name]))
			elif child is CheckBox:
				pass
			elif child is CheckButton:
				pass
			elif child is SpinBox:
				pass
		else:
			_load_fields(child, dict)


func _load():
	pass


## Load the given graph node data and update this panel's controls to reflect
## that data. Ergo, this method must be called only after this panel is ready.
func _from_dict(dict: Dictionary):
	# Load and bind ID
	id_line_edit.connect("text_changed", _on_field_update.bindv(["ID"]))
	fields["ID"] = dict.get("ID", "")
	id_line_edit.text = fields["ID"]
	
	_load_fields(self, dict)


func _set_graph_node(new_graph_node: MonologueGraphNode) -> void:
	graph_node = new_graph_node
	undo_redo = graph_node.get_parent().undo_redo


func _on_file_picker_line_edit_update(file_path: String, _is_valid: bool, field: String) -> void:
	_on_field_update(file_path, field)
	

func _on_te_field_update(node: TextEdit, field: String) -> void:
	_on_field_update(node.text, field)


func _on_option_button_field_update(index: int, node: OptionButton, field: String) -> void:
	var value: String = node.get_item_text(index)
	_on_field_update(value, field)


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
