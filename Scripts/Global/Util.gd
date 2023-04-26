extends Node


func base_config_file(name: String) -> String:
	var dict: Dictionary = {
		"ProjectName": name,
		"VersionProject": "0.1.0",
		"VersionEditor": "0.0.1",
		"DefaultStart": "",
		"ListSpeakers": [
			
		]
	}
	
	return JSON.stringify(dict, "\t")


func check_config_file(path: String):
	assert(FileAccess.file_exists(path))
	
	var raw_text = FileAccess.open(path, FileAccess.READ).get_as_text()
	var data: Dictionary = JSON.parse_string(raw_text)
	
	assert(data.has("ProjectName"))
	assert(data.has("VersionProject"))
	assert(data.has("VersionEditor"))
	assert(data.has("DefaultStart"))
	assert(data.has("ListSpeakers"))
