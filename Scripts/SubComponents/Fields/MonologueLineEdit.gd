extends LineEdit


func _ready() -> void:
	text_changed.connect(_on_field_update)


func _on_field_update(new_text: String) -> void:
	get_parent().field_update.emit(new_text)


func set_value(value: String) -> void:
	text = value
