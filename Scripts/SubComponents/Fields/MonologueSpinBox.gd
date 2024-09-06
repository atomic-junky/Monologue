class_name MonologueSpinBox extends MonologueField


@export var minimum: float = -9223370000000000000
@export var maximum: float = 9223370000000000000
@export var step: float = 1

@onready var label = $Label
@onready var spin_box = $SpinBox


func _ready():
	spin_box.min_value = minimum
	spin_box.max_value = maximum
	spin_box.step = step
	
	var line_edit = spin_box.get_line_edit()
	line_edit.connect("focus_exited", _on_focus_exited)
	line_edit.connect("text_submitted", _on_text_submitted)


func set_label_text(text: String) -> void:
	label.text = text


func propagate(value: Variant) -> void:
	spin_box.value = value if (value is float or value is int) else 0


func _on_focus_exited() -> void:
	_on_text_submitted(spin_box.value)


func _on_text_submitted(new_value: Variant) -> void:
	field_updated.emit(int(new_value))


func _on_value_changed(value: float) -> void:
	field_changed.emit(int(value))
