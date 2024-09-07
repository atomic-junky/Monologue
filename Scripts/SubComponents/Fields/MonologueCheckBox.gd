class_name MonologueCheckBox extends MonologueField


@onready var check_box = $CheckBox


func set_label_text(text: String) -> void:
	check_box.text = text


func propagate(value: Variant) -> void:
	check_box.button_pressed = value if (value is bool) else false
