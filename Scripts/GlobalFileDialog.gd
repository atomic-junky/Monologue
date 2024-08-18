class_name GlobalFileDialog extends FileDialog


var _callback: Callable


func _ready():
	GlobalSignal.add_listener("save_file_request", _on_save_file_request)
	GlobalSignal.add_listener("open_file_request", _on_open_file_request)


func _on_save_file_request(callable: Callable, _filters: PackedStringArray = [], root_subfolder = "") -> void:
	title = "Create New File"
	ok_button_text = "Create"
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	
	_core_request(callable, _filters, root_subfolder)


func _on_open_file_request(callable: Callable, _filters: PackedStringArray = [], root_subfolder = "") -> void:
	title = "Open File"
	ok_button_text = "Open File"
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	_core_request(callable, _filters, root_subfolder)


func _core_request(callable: Callable, _filters: PackedStringArray = [], root_subfolder = "") -> void:
	_callback = callable
	filters = _filters
	root_subfolder = root_subfolder
	
	popup_centered()


func _on_file_selected(path: String) -> void:
	_callback.call(path as String)
