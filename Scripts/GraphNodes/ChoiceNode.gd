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
			var opt_ref = option_reference.instantiate()
			add_child(opt_ref)
			options.append(opt_ref._to_dict())
	
	_update()

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
	
	options.clear()
	
	var nodes = get_parent().data.get("ListNodes")
	for option in dict.get("OptionsID"):
		for node in nodes:
			if node.get("ID") in option:
				options.append(node)
	
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
	for node in get_parent().get_children().filter(func(n): return n is GraphNode):
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

func _update(panel: ChoiceNodePanel = null):
	if panel != null:
		var updated_options = []
		for option in panel.options_container.get_children():
			if option is OptionNode:
				link_option(find_option_dictionary(option.id), false)
				if not option.is_queued_for_deletion():
					updated_options.append(option._to_dict())
		options = updated_options
	
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	for option in options:
		var new_ref = option_reference.instantiate()
		new_ref._from_dict(option)
		
		add_child(new_ref)
		new_ref.sentence_preview.text = option.get("Sentence")
		
		var is_first = get_child_count() <= 1
		set_slot(get_child_count() - 1, is_first, 0, Color("ffffff"), true, 0, Color("ffffff"), arrow_texture01, arrow_texture02, false)
		
		link_option(option)
