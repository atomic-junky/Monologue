@icon("res://Assets/Icons/NodesIcons/Multiple Choice.svg")
class_name ChoiceNode extends MonologueGraphNode


const left_arrow_icon = preload("res://Assets/Icons/NodesIcons/Arrow01.svg")
const right_arrow_icon = preload("res://Assets/Icons/NodesIcons/Arrow02.svg")

var option_scene = preload("res://Objects/GraphNodes/OptionNode.tscn")
var option_nodes = {}


# var options_id := Property.new(LIST, { "type": MonologueList.NODE })


func _ready():
	node_type = "NodeChoice"
	super._ready()
	
	if get_child_count() <= 0:
		add_option()
		add_option()


func add_option(reference: Dictionary = {}):
	var new_option = option_scene.instantiate()
	add_child(new_option)
	new_option.set_count(new_option.get_index() + 1)
	
	if reference:
		new_option._from_dict(reference)
		new_option.preview_label.text = reference.get("Sentence")
		link_option(new_option)
	option_nodes[new_option.id] = new_option
	
	var is_first = get_child_count() <= 1
	set_slot(get_child_count() - 1, is_first, 0, Color("ffffff"), true,
			0, Color("ffffff"), left_arrow_icon, right_arrow_icon, false)


func get_all_options_id() -> Array:
	return option_nodes.keys()


func link_option(option: OptionNode, link: bool = true):
	var index = option.get_index()
	if option.next_id.value is String:  # non-connections are -1 (int)
		var next_node = get_parent().get_node_by_id(option.next_id.value)
		if next_node:
			if link:
				get_parent().connect_node(name, index, next_node.name, 0)
			else:
				get_parent().disconnect_node(name, index, next_node.name, 0)


## Update the NextID of this choice node on the given port.
func update_next_id(from_port: int, next_node: MonologueGraphNode):
	if next_node:
		get_child(from_port).next_id.value = next_node.id
	else:
		get_child(from_port).next_id.value = -1


func _load_connections(_data: Dictionary, _key: String = "") -> void:
	_update()


func _update():
	# disconnect all outbound connections
	for connection in get_parent().get_all_outbound_connections(name):
		var from_port = connection.get("from_port")
		var to_node = connection.get("to_node")
		get_parent().disconnect_node(name, from_port, to_node, 0)
	
	# remove all OptionNodes from ChoiceNode
	var references = option_nodes.values().map(func(o): return o._to_dict())
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	# regenerate options, which also reconnects any next IDs
	option_nodes.clear()
	for reference in references:
		add_option(reference)
