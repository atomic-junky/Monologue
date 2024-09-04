class_name MonologueLineEdit extends MonologueField


var line_edit: LineEdit


func _init(property_name: String, dict_key: String, dict_value: Variant):
	super(property_name, dict_key, dict_value)


func build() -> MonologueField:
	line_edit = LineEdit.new()
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text = value if value is String else ""
	line_edit.connect("focus_exited", _on_focus_exited)
	line_edit.connect("text_submitted", update_value)
	hbox.add_child(line_edit, true)
	return self


func set_panel(new_panel: MonologueNodePanel) -> MonologueField:
	super.set_panel(new_panel)
	if value is not String:
		value = ""
		line_edit.text = value
		panel.graph_node.set(property, value)
	return self


func set_value(new_value: Variant) -> void:
	super.set_value(new_value)
	if line_edit:
		line_edit.text = str(new_value)


func _on_focus_exited():
	update_value(line_edit.text)
