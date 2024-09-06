class_name MonologueLine extends MonologueField


@export var is_sublabel: bool
@export var sublabel_prefix: String = "↳ "

@onready var label = $HBox/FieldLabel
@onready var line_edit = $HBox/VBox/LineEdit
@onready var warning = $HBox/VBox/WarnLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	warning.hide()


func set_label_text(text: String) -> void:
	if is_sublabel:
		label.custom_minimum_size.x = 140
		add_theme_constant_override("margin_left", 25)
		label.add_theme_color_override("font_color", Color("858585"))
		label.text = sublabel_prefix + text
	else:
		label.text = text


func propagate(value: Variant) -> void:
	line_edit.text = str(value)


func _on_focus_exited() -> void:
	_on_text_submitted(line_edit.text)


func _on_text_submitted(new_text: String) -> void:
	field_updated.emit(new_text)
