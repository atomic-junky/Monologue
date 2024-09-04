@icon("res://Assets/Icons/NodesIcons/Root.svg")

class_name RootNodePanel extends MonologueNodePanel


var character_count: int
@onready var character_node = preload("res://Objects/SubComponents/Character.tscn")
@onready var characters_container = $CharactersMainContainer/CharactersContainer

var variable_count: int
@onready var variable_node = preload("res://Objects/SubComponents/Variable.tscn")
@onready var variables_container = $VariablesMainContainer/VariablesContainer


func _ready():
	reload_characters()
	reload_variables()


#func _from_dict(dict):
	#id = dict.get("ID")


func add_character(reference: String = "", update: bool = true):
	var new_node = character_node.instantiate()
	characters_container.add_child(new_node)
	
	var node_id = characters_container.get_children().find(new_node)
	new_node.character_name = reference
	new_node.id = node_id
	new_node.update_callback = update_speakers
	
	if update:
		update_speakers()
	return new_node._to_dict()

 
func add_variable(dict: Dictionary = {}, update: bool = true):
	var new_node = variable_node.instantiate()
	variables_container.add_child(new_node)
	
	if dict:
		new_node.current_name = dict.get("Name")
		match dict.get("Type"):
			"Boolean":
				new_node.current_type_index = 0
				new_node.boolean_edit.button_pressed = dict.get("Value")
			"Integer":
				new_node.current_type_index = 1
				new_node.number_edit.value = dict.get("Value")
			"String":
				new_node.current_type_index = 2
				new_node.current_text = dict.get("Value")
		new_node.update_value_edit()
	new_node.update_callback = update_variables
	
	if update:
		update_variables()
	return new_node._to_dict()


func get_character_node(character_id):
	for node in characters_container.get_children():
		if node.id == character_id:
			return node
	return null


func get_variable_node(variable_name):
	for node in variables_container.get_children():
		if node.current_name == variable_name:
			return node
	return null


func reload_characters():
	for child in characters_container.get_children():
		child.queue_free()
	
	var reloaded = []
	for character in graph_node.speakers:
		reloaded.append(add_character(character.get("Reference"), false))
	return reloaded


func reload_variables():
	for child in variables_container.get_children():
		child.queue_free()
	
	var reloaded = []
	for variable in graph_node.variables:
		reloaded.append(add_variable(variable, false))
	return reloaded


func update_speakers():
	var all_nodes = characters_container.get_children()
	var updated_speakers = []
	
	for child in all_nodes:
		if child.is_queued_for_deletion():
			continue
		
		child.id = all_nodes.find(child)
		updated_speakers.append(child._to_dict())
	
	_on_node_property_change(["speakers"], [updated_speakers])


func update_variables():
	var all_nodes = variables_container.get_children()
	var updated_variables = []
	
	for child in all_nodes:
		if child.is_queued_for_deletion():
			continue
		
		updated_variables.append(child._to_dict())
	
	_on_node_property_change(["variables"], [updated_variables])


func update_controls():
	for i in graph_node.speakers.size():
		characters_container.get_child(i)._from_dict(graph_node.speakers[i])
	
	for j in graph_node.variables.size():
		variables_container.get_child(j)._from_dict(graph_node.variables[j])
