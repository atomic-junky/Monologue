@icon("res://Assets/Icons/NodesIcons/Root.svg")

class_name RootNodePanel

extends VBoxContainer


@onready var character_node = preload("res://Objects/SubComponents/Character.tscn")
@onready var characters_container = $CharactersMainContainer/CharactersContainer

@onready var variable_node = preload("res://Objects/SubComponents/Variable.tscn")
@onready var variables_container = $VariablesMainContainer/VariablesContainer

var graph_node

var id = ""


func _ready():
	for character in graph_node.get_parent().speakers:
		add_character(character.get("Reference"))
	
	for variable in graph_node.get_parent().variables:
		add_variable(true, variable)

func _from_dict(dict):
	id = dict.get("ID")


func add_character(reference: String = ""):
	var new_node = character_node.instantiate()
	characters_container.add_child(new_node)
	
	var node_id = characters_container.get_children().find(new_node)
	var ref_input: LineEdit = new_node.ref_input
	
	ref_input.text = reference
	ref_input.text_changed.connect(text_submitted_callback)
	new_node.id = node_id
	new_node.root_node = self
	
	update_speakers()

 
func add_variable(init: bool = false, dict: Dictionary = {}):
	var new_node = variable_node.instantiate()
	new_node.update_callback = update_variables
	variables_container.add_child(new_node)
	
	if init: # Called from _ready()
		new_node.name_input.text = dict.get("Name")
		
		match dict.get("Type"):
			"Boolean":
				new_node.type_selection.select(0)
				new_node.boolean_edit.button_pressed = dict.get("Value")
			"Integer":
				new_node.type_selection.select(1)
				new_node.number_edit.value = dict.get("Value")
			"String":
				new_node.type_selection.select(2)
				new_node.string_edit.text = dict.get("Value")
	
		new_node.update_value_edit()


## Call the update_speakers function when a character node is updated
func text_submitted_callback(_new_text):
	update_speakers()


## Update the GraphEdit speakers variable based on all character nodes
func update_speakers():
	var all_nodes = characters_container.get_children()
	var updated_speakers = []
	
	for child in all_nodes:
		if child.is_queued_for_deletion():
			continue
		
		child.id = all_nodes.find(child)
		
		updated_speakers.append(child._to_dict())
		
	graph_node.get_parent().speakers = updated_speakers


## Update the GraphEdit variables variable based on all variables nodes
func update_variables():
	var all_nodes = variables_container.get_children()
	var updated_variables = []
	
	for child in all_nodes:
		if child.is_queued_for_deletion():
			continue
		
		updated_variables.append(child._to_dict())
		
	graph_node.get_parent().variables = updated_variables
