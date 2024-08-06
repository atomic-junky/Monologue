## Represents the graph area which creates and connects MonologueGraphNodes.
class_name MonologueGraphEdit
extends GraphEdit


@onready var close_button = preload("res://Objects/SubComponents/CloseButton.tscn")

## Action queue history for undo/redo functionality.
var action_queue: ActionQueue = ActionQueue.new()
## JSON dialogue data such as characters and variables.
var data: Dictionary
## The filepath to the dialogue JSON.
var file_path: String
## List of dialogue speakers (characters) in the JSON.
var speakers = []
## List of dialogue variables in the JSON.
var variables = []

## The actively selected graphnode, for side panel updates.
var active_graphnode: Node
## Reference to the mother Control node that oversees all Monologue operations.
var control_node
## Checks if a graphnode is currently selected.
var graphnode_selected = false

var mouse_pressed = false
var moving_mode = false
var selection_mode = false


func _input(event):
	if event is InputEventMouseButton:
		mouse_pressed = event.is_pressed()
	moving_mode = false
	selection_mode = false
	# check if user is selecting and dragging a graphnode
	if event is InputEventMouseMotion and mouse_pressed:
		selection_mode = true
		moving_mode = graphnode_selected


## Disconnect an existing connection of the given graphnode from a given port.
func disconnect_connection_from_node(from_node: StringName, from_port: int):
	for connection in get_connection_list():
		if connection.get("from_node") == from_node:
			var to_node = connection.get("to_node")
			var to_port = connection.get("to_port")
			disconnect_node(from_node, from_port, to_node, to_port)


## Deletes the given graphnode and return its dictionary data.
func free_graphnode(node: GraphNode) -> Dictionary:
	# Disconnect all empty connections
	for n in get_all_connections_to_node(node.name):
		for co in get_connection_list():
			if co.get("from_node") == n.name and co.get("to_node") == node.name:
				disconnect_node(co.get("from_node"), co.get("from_port"), co.get("to_node"), co.get("to_port"))
	
	for n in get_all_connections_from_node(node.name):
		for co in get_connection_list():
			if co.get("from_node") == node.name and co.get("to_node") == n.name:
				disconnect_node(co.get("from_node"), co.get("from_port"), co.get("to_node"), co.get("to_port"))
	
	# retrive node data before deletion
	var node_data = node._to_dict()
	node.queue_free()
	return node_data


## Find all known connections from the given graphnode.
func get_all_connections_from_node(from_node: StringName):
	var connections = []
	for connection in get_connection_list():
		if connection.get("from_node") == from_node:
			var to = get_node_or_null(NodePath(connection.get("to_node")))
			connections.append(to)
	return connections


## Find all existing connections that connect to the given graphnode.
func get_all_connections_to_node(from_node: StringName):
	var connections = []
	for connection in get_connection_list():
		if connection.get("to_node") == from_node:
			var from = get_node_or_null(NodePath(connection.get("from_node")))
			connections.append(from)
	return connections


## Find connections of the given [param from_node] at its [param from_port].
## In Monologue's architecture, it should return a list with only 1 connection.
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


func _on_node_selected(node):
	active_graphnode = node
	graphnode_selected = true


func _on_node_deselected(_node):
	active_graphnode = null
	graphnode_selected = false


func _on_child_entered_tree(node: Node):
	if node is RootNode or not node is GraphNode:
		return
	
	var node_header = node.get_children(true)[0]
	var close_btn: TextureButton = close_button.instantiate()
	close_btn.connect("pressed", free_graphnode.bind(node))
	node_header.add_child(close_btn)
