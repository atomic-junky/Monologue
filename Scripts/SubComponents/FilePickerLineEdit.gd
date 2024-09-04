class_name FilePickerLineEdit extends VBoxContainer


signal new_file_path(file_path: String)

@export var base_file_path: String
@export var filters: PackedStringArray

@onready var line_edit: LineEdit = $LineEdit
@onready var picker_button: Button = $LineEdit/FilePickerButton
@onready var warn_label: Label = $WarnLabel


## Used by MonologueValue to accept any value as filepath.
func set_variant(value: Variant):
	_on_text_submitted(value if value is String else "")


func _on_file_selected(path: String):
	line_edit.text = Path.absolute_to_relative(path, base_file_path)
	_on_focus_exited()


func _on_focus_exited() -> void:
	_on_text_submitted(line_edit.text)


func _on_picker_button_pressed():
	GlobalSignal.emit("open_file_request",
			[_on_file_selected, filters, base_file_path.get_base_dir()])


func _on_text_submitted(file_path: String) -> bool:
	warn_label.hide()
	var is_valid = true
	
	file_path = file_path.lstrip(" ")
	file_path = file_path.rstrip(" ")
	
	if file_path == "":
		pass
	else:
		var abs_file_path = Path.relative_to_absolute(file_path, base_file_path)
		
		if not FileAccess.file_exists(abs_file_path):
			warn_label.show()
			warn_label.text = "File path not found!"
			is_valid = false
		else:
			var correct_suffix: bool = false
			var file_name: String = abs_file_path.get_file()
			for filter in filters:
				var targets = _split_match(filter)
				for target in targets:
					if file_name.match(target):
						correct_suffix = true
						break
			
			if not correct_suffix:
				warn_label.show()
				var formats = Array(filters).map(_split_match)
				var text = ", ".join(formats.map(func(f): return ", ".join(f)))
				warn_label.text = "File must match: %s" % text
				is_valid = false
	
	new_file_path.emit(file_path)
	line_edit.text = file_path
	return is_valid


func _split_match(filter: String) -> Array:
	return filter.split(";")[0].split(",")
