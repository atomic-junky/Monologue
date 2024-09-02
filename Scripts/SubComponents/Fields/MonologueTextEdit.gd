extends TextEdit


func _ready() -> void:
	text_changed.connect(_on_field_update)


func _on_field_update() -> void:
	var value = text
	get_parent().field_update.emit(text)


func set_value(value: String) -> void:
	text = value
	print(value)
