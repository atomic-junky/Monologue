class_name MonologueTextEdit extends MonologueField


var text_edit: TextEdit
var preview_label: RichTextLabel


func build() -> MonologueField:
	text_edit = TextEdit.new()
	text_edit.caret_blink = true
	text_edit.custom_minimum_size.y = 200
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.text = value if value is String else ""
	text_edit.connect("focus_exited", _on_focus_exited)
	hbox.add_child(text_edit, true)
	return self


func preview(rich_label: RichTextLabel) -> MonologueField:
	preview_label = rich_label
	text_edit.connect("text_changed", _on_text_changed)
	_on_text_changed()
	return self


func set_value(new_value: Variant) -> void:
	super.set_value(new_value)
	if text_edit:
		text_edit.text = str(new_value)


func _on_focus_exited():
	update_value(text_edit.text)


func _on_text_changed():
	preview_label.text = text_edit.text
