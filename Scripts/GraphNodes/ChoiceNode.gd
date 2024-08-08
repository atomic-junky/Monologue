@icon("res://Assets/Icons/NodesIcons/Multiple Choice.svg")

class_name ChoiceNode

extends MonologueGraphNode


const arrow_texture01 = preload("res://Assets/Icons/NodesIcons/Arrow01.svg")
const arrow_texture02 = preload("res://Assets/Icons/NodesIcons/Arrow02.svg")

@onready var option_reference = preload("res://Objects/SubComponents/OptionReference.tscn")

var options = []


func _ready():
	node_type = "NodeChoice"
	title = node_type
	
	if len(options) <= 0:
		for _i in range(2):
			create_option()
	
	_update()


## Creates an option reference. If [param from_copy] is not specified,
## a new option is created. Otherwise, it pulls the given option data
## and tracks it if it does not already exist.
func create_option(from_copy: Dictionary = {}):
	var new_option = option_reference.instantiate()
	add_child(new_option)
	if not from_copy or from_copy.is_empty():
		options.append(new_option._to_dict())
	else:
		# add to options list if it does not already exist
		if not find_option_dictionary(from_copy.get("ID")):
			options.append(from_copy)
		
		new_option._from_dict(from_copy)
		new_option.sentence_preview.text = from_copy.get("Sentence")
		var is_first = get_child_count() <= 1
		set_slot(get_child_count() - 1, is_first, 0, Color("ffffff"), true,
				0, Color("ffffff"), arrow_texture01, arrow_texture02, false)
		link_option(from_copy)


func _to_dict() -> Dictionary:
	return {
		"$type": node_type,
		"ID": id,
		"OptionsID": get_all_options_id(),
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}

func _from_dict(dict):
	id = dict.get("ID")
	
	# get list of all nodes in the graph
	var nodes = get_parent().data.get("ListNodes")
	options.clear()
	for option in dict.get("OptionsID"):
		for node in nodes:
			# if the OptionNode's ID is in NodeChoice's OptionIDs, add it
			if node.get("ID") in option:
				options.append(node)
	
	var editor_position = dict.get("EditorPosition")
	position_offset.x = editor_position.get("x")
	position_offset.y = editor_position.get("y")
	_update()


## Everytime the OptionNode updates from the panel to the ChoiceNode,
## the reference to that dictionary item is different. This retrieves it by ID.
func find_option_dictionary(search_id: String) -> Dictionary:
	var result = {}
	for option in options:
		if option.get("ID") == search_id:
			result = option
			break
	return result


func get_all_options_id() -> Array:
	var ids = []
	for child in get_children():
		if is_instance_of(child, PanelContainer) and child.id != null:
			ids.append(child.id)
	return ids


func get_graph_node(node_id):
	var graph_node = null
	for node in get_parent().get_children():
		if node_id is String and node.id == node_id:
			graph_node = node
	return graph_node


func link_option(option_dictionary: Dictionary, establish_link: bool = true):
	var option_index = options.find(option_dictionary)
	var next_node = get_graph_node(option_dictionary.get("NextID"))
	if next_node:
		if establish_link:
			get_parent().connect_node(name, option_index, next_node.name, 0)
		else:
			get_parent().disconnect_node(name, option_index, next_node.name, 0)


func update_next_id(from_port: int, next_node: MonologueGraphNode):
	if next_node:
		# nodes should not have multiple next_nodes, so only update
		# if there is no existing NextID
		if str(options[from_port].get("NextID")) == "-1":
			options[from_port]["NextID"] = next_node.id
	else:
		# if there is no next_node target, disconnect the NextID (set to -1)
		options[from_port]["NextID"] = -1
	
	# if side panel is up, the NextID change needs to propagate to the panel
	var panel = get_parent().control_node.side_panel_node.current_panel
	if panel and self == panel.graph_node:
		var option_id = options[from_port].get("ID")
		var option_node: OptionNode = panel.get_option_node(option_id)
		option_node.next_id = options[from_port].get("NextID")
		option_node.update_ref()


## Updates the given option's UI text on the node. This is introduced because
## of undo/redo functionality only triggering on focus_exited() for certain
## text controls. This loses the smooth, real-time text update Monologue
## used to have, and this is to maintain that user experience.
func update_option_text(option_id, text):
	for child in get_children():
		if child is OptionReference and child.id == option_id:
			child.sentence_preview.text = text
			return


func _update(panel: ChoiceNodePanel = null):
	if panel != null:
		panel.disconnect_all_option_links()
		options = panel.get_panel_option_data()
	
	# remove all OptionReferences from ChoiceNode
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	# regenerate options
	for option in options:
		create_option(option)
