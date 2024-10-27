@icon("res://Assets/Icons/Graph/choice.svg")

class_name ChoiceNode
extends MonologueGraphNode


const left_arrow_icon = preload("res://Assets/Icons/NodesIcons/Arrow01.svg")
const right_arrow_icon = preload("res://Assets/Icons/NodesIcons/Arrow02.svg")

@onready var option_reference = preload("res://Objects/SubComponents/OptionReference.tscn")

var options = []


func _ready():
	node_type = "NodeChoice"
	title = node_type
	
	if len(options) <= 0:
		for _i in range(2):
			add_option_reference()


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
	
	var editor_position = dict.get("EditorPosition")
	position_offset.x = editor_position.get("x")
	position_offset.y = editor_position.get("y")
	
	_update()


func add_option_reference(reference: Dictionary = {}):
	var new_option = option_reference.instantiate()
	add_child(new_option)
	
	if reference:
		new_option._from_dict(reference)
		new_option.sentence_preview.text = reference.get("Sentence")
		link_option(reference)
	else:
		options.append(new_option._to_dict())  # new option from nothing
	
	var is_first = get_child_count() <= 1
	set_slot(get_child_count() - 1, is_first, 0, Color("ffffff"), true,
			0, Color("ffffff"), left_arrow_icon, right_arrow_icon, false)


func get_all_options_id() -> Array:
	var ids = []
	for dict in options:
		ids.append(dict.get("ID"))
	return ids

func get_graph_node(node_id):
	var graph_node = null
	for node in get_parent().get_children().filter(func(n): return n is GraphNode):
		if node_id is String and node.id == node_id:
			graph_node = node
	return graph_node

func get_option_reference(option_id: String):
	for child in get_children():
		if child is OptionReference and child.id == option_id:
			return child
	return null


func link_option(option_dict: Dictionary, link: bool = true):
	var index = options.find(option_dict)
	var next_id = option_dict.get("NextID")
	
	if next_id is String:  # Monologue records non-connections as -1 (int)
		var next_node = get_parent().get_node_by_id(next_id)
		if next_node:
			if link:
				get_parent().connect_node(name, index, next_node.name, 0)
			else:
				get_parent().disconnect_node(name, index, next_node.name, 0)


## Update the NextID of this choice node on the given port.
func update_next_id(from_port: int, next_node: MonologueGraphNode):
	if next_node:
		options[from_port]["NextID"] = next_node.id
	else:
		options[from_port]["NextID"] = -1
	GlobalSignal.emit("update_option_next_id", [self, from_port])


func _load_connections(_data: Dictionary, _key: String = "") -> void:
	_update()


func _update(panel: ChoiceNodePanel = null):
	if panel != null:
		if options.size() != panel.options_container.get_child_count():
			panel.reload_options()
		else:
			panel.update_options()
	
	# disconnect all outbound connections
	for connection in get_parent().get_all_outbound_connections(name):
		var from_port = connection.get("from_port")
		var to_node = connection.get("to_node")
		get_parent().disconnect_node(name, from_port, to_node, 0)
	
	# remove all OptionReferences from ChoiceNode
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	# regenerate options, which also reconnects any next IDs
	for option in options:
		add_option_reference(option)
