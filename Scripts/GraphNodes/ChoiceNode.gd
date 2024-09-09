@icon("res://Assets/Icons/NodesIcons/Multiple Choice.svg")
class_name ChoiceNode extends MonologueGraphNode


const left_arrow_icon = preload("res://Assets/Icons/NodesIcons/Arrow01.svg")
const right_arrow_icon = preload("res://Assets/Icons/NodesIcons/Arrow02.svg")

var option_scene = preload("res://Objects/GraphNodes/OptionNode.tscn")
var options := Property.new(LIST, { "type": MonologueList.OPTION }, [])


func _ready():
	node_type = "NodeChoice"
	super._ready()
	options.setters["add_callback"] = add_option
	options.setters["list"] = {}
	options.callers["set_label_visible"] = [false]
	
	if get_child_count() <= 0:
		add_option()
		add_option()


func add_option(reference: Dictionary = {}) -> OptionNode:
	var new_option = option_scene.instantiate()
	add_child(new_option)
	new_option.set_count(new_option.get_index() + 1)
	
	if reference:
		new_option._from_dict(reference)
		new_option.preview_label.text = reference.get("Sentence")
		link_option(new_option)
	else:
		options.value.append(new_option.id.value)
		options.setters["list"][new_option.id.value] = new_option
	
	var is_first = get_child_count() <= 1
	set_slot(get_child_count() - 1, is_first, 0, Color("ffffff"), true,
			0, Color("ffffff"), left_arrow_icon, right_arrow_icon, false)
	return new_option


func get_option_by_id(option_id: String) -> OptionNode:
	for node in get_children():
		if node.id.value == option_id:
			return node
	return null


func link_option(option: OptionNode, link: bool = true):
	var index = option.get_index()
	if option.next_id is String:  # non-connections are -1 (int)
		var next_node = get_parent().get_node_by_id(option.next_id.value)
		if next_node:
			if link:
				get_parent().connect_node(name, index, next_node.name, 0)
			else:
				get_parent().disconnect_node(name, index, next_node.name, 0)


## Update the NextID of this choice node on the given port.
func update_next_id(from_port: int, next_node: MonologueGraphNode):
	if next_node:
		get_child(from_port).next_id = next_node.id.value
	else:
		get_child(from_port).next_id = -1


func _from_dict(dict: Dictionary) -> void:
	# remove existing options and reload them
	if options.value.size() > 0:
		options.setters["list"] = {}
		options.value = []
		for child in get_children():
			remove_child(child)
			child.queue_free()
	
	options.value = dict.get("Options", dict.get("OptionsID", []))
	_load_position(dict)
	# overridden to prevent _update() from happening too early here


func _load_connections(_data: Dictionary, _key: String = "") -> void:
	# called after _load_nodes() in MonologueControl, this is used to
	# load embedded OptionNodes which automatically forms the connections
	for option_id in options.value:
		var reference = get_parent().base_options[option_id]
		var loaded_option = add_option(reference)
		options.setters["list"][loaded_option.id.value] = loaded_option


func _update():
	# disconnect all outbound connections
	for connection in get_parent().get_all_outbound_connections(name):
		var from_port = connection.get("from_port")
		var to_node = connection.get("to_node")
		get_parent().disconnect_node(name, from_port, to_node, 0)
	
	for node in get_children():
		link_option(node)
	super._update()
