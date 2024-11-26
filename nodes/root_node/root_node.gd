@icon("res://ui/assets/icons/root.svg")
class_name RootNode extends MonologueGraphNode


var speakers  := Property.new(LIST, {}, [])
var variables := Property.new(LIST, {}, [])

var _speaker_references = []
var _variable_references = []


func _ready():
	node_type = "NodeRoot"
	super._ready()
	
	load_speakers(get_parent().speakers)
	speakers.setters["add_callback"] = add_speaker
	speakers.setters["get_callback"] = get_speakers
	speakers.connect("preview", load_speakers)
	
	load_variables(get_parent().variables)
	variables.setters["add_callback"] = add_variable
	variables.setters["get_callback"] = get_variables
	variables.connect("preview", load_variables)


func add_speaker(data: Dictionary = {}) -> MonologueCharacter:
	var speaker = MonologueCharacter.new(self)
	if data:
		speaker._from_dict(data)
	speaker.id.value = _speaker_references.size()
	_speaker_references.append(speaker)
	return speaker


func add_variable(data: Dictionary = {}) -> MonologueVariable:
	var variable = MonologueVariable.new(self)
	if data:
		variable._from_dict(data)
	variable.index = _variable_references.size()
	_variable_references.append(variable)
	return variable


func get_speakers():
	return _speaker_references


func get_variables():
	return _variable_references


## Perform initial loading of speakers and set indexes correctly.
func load_speakers(new_speaker_list: Array):
	_speaker_references.clear()
	var ascending = func(a, b): return a.get("ID") < b.get("ID")
	new_speaker_list.sort_custom(ascending)
	for speaker_data in new_speaker_list:
		add_speaker(speaker_data)
	
	if _speaker_references.is_empty():
		var narrator = add_speaker()
		narrator.name.value = "_NARRATOR"
		new_speaker_list.append(narrator._to_dict())
	speakers.value = new_speaker_list
	get_graph_edit().speakers = new_speaker_list


func load_variables(new_variable_list: Array):
	_variable_references.clear()
	for variable in new_variable_list:
		add_variable(variable)
	variables.value = new_variable_list
	get_graph_edit().variables = new_variable_list


func _to_fields(_dict: Dictionary) -> void:
	pass  # speakers and variables are stored outside of root node
