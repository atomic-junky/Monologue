extends GraphEdit


@onready var close_button = preload("res://Objects/SubComponents/CloseButton.tscn")

var file_path: String

var speakers = []
var variables = []
var mouse_pressed = false
var selection_mode = false

var graphnode_selected = false
var moving_mode = false

var data: Dictionary

var control_node

func _input(event):
	if event is InputEventMouseButton:
		mouse_pressed = event.is_pressed()
	
	selection_mode = false
	moving_mode = false
	if event is InputEventMouseMotion and mouse_pressed:
		selection_mode = true
		moving_mode = graphnode_selected

func disconnect_all_connections_from_node(from_node: StringName):
	for connection in get_connection_list():
		if connection.get("from_node") == from_node:
			var from_port = connection.get("from_port")
			var to_node = connection.get("to_node")
			var to_port = connection.get("to_port")
			disconnect_node(from_node, from_port, to_node, to_port)

func get_all_connections_from_node(from_node: StringName):
	var connections = []
	
	for connection in get_connection_list():
		if connection.get("from_node") == from_node:
			var to = get_node_or_null(NodePath(connection.get("to_node")))
			connections.append(to)
	
	return connections

func get_all_connections_to_node(from_node: StringName):
	var connections = []
	
	for connection in get_connection_list():
		if connection.get("to_node") == from_node:
			var from = get_node_or_null(NodePath(connection.get("from_node")))
			connections.append(from)
	
	return connections

func get_all_connections_from_slot(from_node: StringName, from_port: int):
	var connections = []
	
	for connection in get_connection_list():
		if connection.get("from_node") == from_node and connection.get("from_port") == from_port:
			var to = get_node_or_null(NodePath(connection.get("to_node")))
			connections.append(to)

	return connections

func get_linked_bridge_node(target_number):
	for node in get_children():
		if node.node_type == "NodeBridgeOut" and node.number_selector.value == target_number:
			return node

func get_free_bridge_number(_n=1, lp_max=50):
	for node in get_children():
		if (node.node_type == "NodeBridgeOut" or node.node_type == "NodeBridgeIn") and node.number_selector.value == _n:
			if lp_max <= 0:
				return _n
				
			return get_free_bridge_number(_n+1, lp_max-1)
	return _n

func is_option_node_exciste(node_id):
	for node in get_children():
		if node.node_type != "NodeChoice":
			continue
		var node_options_id: Array = node.get_all_options_id()
		if node_options_id.has(node_id):
			return true
	return false

func _on_node_selected(_node):
	graphnode_selected = true

func _on_node_deselected(_node):
	graphnode_selected = false

func free_graphnode(node: GraphNode):
	# Disconnect all empty connections
	for n in get_all_connections_to_node(node.name):
		for co in get_connection_list():
			if co.get("from_node") == n.name and co.get("to_node") == node.name:
				disconnect_node(co.get("from_node"), co.get("from_port"), co.get("to_node"), co.get("to_port"))
	
	for n in get_all_connections_from_node(node.name):
		for co in get_connection_list():
			if co.get("from_node") == node.name and co.get("to_node") == n.name:
				disconnect_node(co.get("from_node"), co.get("from_port"), co.get("to_node"), co.get("to_port"))
		
	node.queue_free()

func _on_child_entered_tree(node: Node):
	if node is RootNode or not node is GraphNode:
		return
	
	var node_header = node.get_children(true)[0]
	var close_btn: TextureButton = close_button.instantiate()
	close_btn.connect("pressed", free_graphnode.bind(node))
	node_header.add_child(close_btn)
