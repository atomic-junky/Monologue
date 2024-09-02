class_name MonologueField extends HBoxContainer


signal field_update(value: Variant)

@export var field: Control

var _label: Label = Label.new()


func _ready() -> void:
	_label.custom_minimum_size.x = 175
	_label.size_flags_vertical = VERTICAL_ALIGNMENT_FILL
	
	add_child(_label)
	move_child(_label, 0)


func load_field(text_label: String, separator: bool = false) -> MonologueField:
	_label.text = text_label
	
	return self


func set_value(value: Variant) -> void:
	field.set_value(value)
