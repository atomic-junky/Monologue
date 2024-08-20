class_name FilePickerButton extends Button


@onready var linked_lined_edit: FilePickerLineEdit = get_parent()


func _on_pressed():
	GlobalSignal.emit("open_file_request", [_file_selected_callback, linked_lined_edit.filters])


func _file_selected_callback(path: String):
	linked_lined_edit.text = path
	linked_lined_edit._convert_to_relative()
	linked_lined_edit._path_update()
