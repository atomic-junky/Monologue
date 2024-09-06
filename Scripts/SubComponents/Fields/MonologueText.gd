class_name MonologueText extends MonologueField


@onready var label = $Label
@onready var text_edit = $TextEdit


func set_label_text(text: String) -> void:
	label.text = text


func propagate(value: Variant) -> void:
	text_edit.text = str(value)


func _on_focus_exited() -> void:
	field_updated.emit(text_edit.text)


func _on_text_changed() -> void:
	field_changed.emit(text_edit.text)
