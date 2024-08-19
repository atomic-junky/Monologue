extends Node


const MAX_FILENAME_LENGTH = 48


func check_config_file(path: String):
	assert(FileAccess.file_exists(path))
	
	var raw_text = FileAccess.open(path, FileAccess.READ).get_as_text()
	var data: Dictionary = JSON.parse_string(raw_text)
	
	assert(data.has("ProjectName"))
	assert(data.has("VersionProject"))
	assert(data.has("VersionEditor"))
	assert(data.has("DefaultStart"))
	assert(data.has("ListSpeakers"))


func is_equal(a: Variant, b: Variant) -> bool:
	var type_a = typeof(a)
	var type_b = typeof(b)
	
	if type_a == type_b:
		match type_a:
			TYPE_DICTIONARY, TYPE_OBJECT:
				return a.hash() == b.hash()
			TYPE_ARRAY:
				if a.size() == b.size():
					var i = 0
					var premise = true
					while i < a.size() and premise:
						premise = is_equal(a[i], b[i])
						i = i + 1
					return premise
			_:
				return a == b
	
	return false


## Try to merge two list of dictionaries, new values overriding the old.
func merge_dict(old_list: Array, new_list: Array, id_key: String) -> Array:
	# first, map keys to existing list of old dictionaries
	var merger: Dictionary = {}
	for old_dict in old_list:
		if old_dict is Dictionary:
			merger[old_dict.get(id_key)] = old_dict
	
	# then, override/merge new dictionaries to the existing list
	for new_dict in new_list:
		if new_dict is Dictionary:
			var new_key = new_dict.get(id_key)
			var combine = merger.get(new_key, {})
			combine.merge(new_dict, true)
			merger[new_key] = combine
	
	return merger.values()  # only an array of dictionaries is returned


## Left-truncate a given filename string based on MAX_FILENAME_LENGTH.
func truncate_filename(filename: String):
	var truncated = filename
	if filename.length() > MAX_FILENAME_LENGTH:
		truncated = "..." + filename.right(MAX_FILENAME_LENGTH - 3)
	return truncated
