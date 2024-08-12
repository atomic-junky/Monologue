class_name FilePickerLineEdit extends LineEdit


signal new_file_path(file_path: String, is_valid: bool)

@export var filters: Array[String]
@export var warn_label: Label

@onready var file_picker_btn: FilePickerButton = $FilePickerButton

var is_valid: bool = true


func _ready() -> void:
	assert(warn_label != null)
	warn_label.hide()
		

func absolute_to_relative(root_file_path: String) -> String:
	var path: String = text
	
	assert(FileAccess.file_exists(path))
	assert(FileAccess.file_exists(root_file_path))
	assert(root_file_path.is_absolute_path())
	
	if not path.is_absolute_path():
		return
	
	var root_dir: String = root_file_path.replace(root_file_path.get_file(), "")
	root_dir = root_dir.replace("\\", "/")
	root_dir = root_dir.replace("//", "/")
	var root_array: PackedStringArray = root_dir.split("/", false)

	var splt_path: String = path.replace(path.get_file(), "")
	splt_path = splt_path.replace("\\", "/")
	splt_path = splt_path.replace("//", "/")
	var path_array: PackedStringArray = splt_path.split("/", false)
	
	var final_path = []
	var back = []
	var forward = []
	var max_path_size = max(root_array.size(), path_array.size())
	for i in max_path_size:
		var root_index = root_array[i] if i < root_array.size() else null
		var path_index = path_array[i] if i < path_array.size() else null
		
		if root_index == path_index:
			continue
		else:
			if root_index != null:
				back.append("..")
			if path_index != null:
				forward.append(path_index)
	
	for i in back.size():
		final_path.append("..")
	
	for i in forward:
		final_path.append(i)
	
	final_path = back + forward
	
	final_path.append(path.get_file())
	var relative_path = ""
	for step in final_path:
		relative_path = relative_path.path_join(step)
	
	return relative_path


func _on_text_changed(new_text: String) -> void:
	_path_update()


func _path_update() -> void:
	var file_path: String = text
	
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
	
	# TODO: Make MonologueControl global to access it anywhere!
	var control: MonologueControl = get_node("/root/App/PanelContainer/Control")
	var root_file_path: String = control.get_current_graph_edit().file_path
	
	absolute_to_relative(root_file_path)
	
	new_file_path.emit(file_path, is_valid)

