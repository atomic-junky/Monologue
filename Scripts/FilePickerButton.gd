class_name FilePickerButton extends Button


@export var linked_lined_edit: LineEdit


func _on_pressed():
	GlobalSignal.emit("open_file_request", [_file_selected_callback, ["*.mp3"]])


func _file_selected_callback(path: String):
	linked_lined_edit.text = path
