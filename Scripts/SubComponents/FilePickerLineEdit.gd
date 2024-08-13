class_name FilePickerLineEdit extends LineEdit


signal new_file_path(file_path: String, is_valid: bool)

@export var filters: Array[String]
@export var warn_label: Label
@export var base_file_path: String

@onready var file_picker_btn: FilePickerButton = $FilePickerButton

var is_valid: bool = true


func _ready() -> void:
	assert(warn_label != null)
	warn_label.hide()


func _convert_to_relative() -> void:
	text = Path.absolute_to_relative(text, base_file_path)


func _on_text_changed(new_text: String) -> void:
	_path_update()


func _path_update() -> void:
	var file_path: String = Path.relative_to_absolute(text, base_file_path)
	
	warn_label.hide()
	is_valid = true
	
	if file_path == "":
		pass
	elif not FileAccess.file_exists(file_path):
		warn_label.show()
		warn_label.text = "File path not found!"
		is_valid = false
	else:
		var correct_suffix: bool = false
		for filter in filters:
			var end_match: String = filter
			var file_name: String = file_path.get_file()
			if file_name.match(end_match):
				correct_suffix = true
		
		if not correct_suffix:
			warn_label.show()
			warn_label.text = "You must select a file that match %s!" % ", ".join(filters)
			is_valid = false
	
	new_file_path.emit(file_path, is_valid)

