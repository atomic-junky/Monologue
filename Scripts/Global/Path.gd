extends Node


func split_path(path: String) -> PackedStringArray:
	var splt_path: String = path.replace(path.get_file(), "")
	splt_path = splt_path.replace("\\", "/")
	splt_path = splt_path.replace("//", "/")
	return splt_path.split("/", false)



func absolute_to_relative(path: String, root_file_path: String) -> String:
	assert(FileAccess.file_exists(path))
	assert(FileAccess.file_exists(root_file_path))
	assert(root_file_path.is_absolute_path())
	
	if not path.is_absolute_path():
		return path
	
	var root_array: PackedStringArray = split_path(root_file_path)
	var path_array: PackedStringArray = split_path(path)
	
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


func relative_to_absolute(path: String, root_file_path: String) -> String:
	assert(FileAccess.file_exists(root_file_path))
	assert(root_file_path.is_absolute_path())
	
	if path.is_absolute_path():
		return path
	
	var root_array: PackedStringArray = split_path(root_file_path)
	var path_array: PackedStringArray = split_path(path)
	
	var back_count = path.count("..")
	var core_path = Array(root_array).slice(0, root_array.size()-back_count)
	var to_file = Array(path_array).slice(back_count)
	var final_path = Array(core_path) + to_file
	
	final_path.append(path.get_file())
	var absolute_path = ""
	for step in final_path:
		absolute_path = absolute_path.path_join(step)
		
	return absolute_path
