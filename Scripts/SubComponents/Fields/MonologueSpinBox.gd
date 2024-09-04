class_name MonologueSpinBox extends MonologueField


var spin_box: SpinBox


func build() -> MonologueField:
	spin_box = SpinBox.new()
	spin_box.set_value_no_signal(value if value is int else 0)
	var line_edit = spin_box.get_line_edit()
	line_edit.connect("focus_exited", _on_focus_exited)
	line_edit.connect("text_submitted", update_value)
	hbox.add_child(spin_box, true)
	return self


func set_panel(new_panel: MonologueNodePanel) -> MonologueField:
	super.set_panel(new_panel)
	if value is not int:
		value = 0
		spin_box.set_value_no_signal(value)
		panel.graph_node.set(property, value)
	return self


func set_value(new_value: Variant) -> void:
	var number = new_value if new_value is int else 0
	super.set_value(number)
	if spin_box:
		spin_box.set_value_no_signal(number)


func _on_focus_exited():
	update_value(spin_box.value)
