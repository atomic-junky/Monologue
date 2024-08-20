class_name GlobalFileDialog extends FileDialog


var _callback: Callable


func _ready():
	GlobalSignal.add_listener("save_file_request", _on_save_file_request)
	GlobalSignal.add_listener("open_file_request", _on_open_file_request)


func _on_save_file_request(callable: Callable,
		filter_list: PackedStringArray = [], root_subdir: String = "") -> void:
	title = "Create New File"
	ok_button_text = "Create"
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	
	_core_request(callable, filter_list, root_subdir)


func _on_open_file_request(callable: Callable,
		filter_list: PackedStringArray = [], root_subdir: String = "") -> void:
	title = "Open File"
	ok_button_text = "Open File"
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	_core_request(callable, filter_list, root_subdir)


func _core_request(callable: Callable, filter_list: PackedStringArray = [],
		root_subdir: String = "") -> void:
	_callback = callable
	filters = filter_list
	root_subfolder = root_subdir
	
	popup_centered()


func _on_file_selected(path: String) -> void:
	_callback.call(path as String)
