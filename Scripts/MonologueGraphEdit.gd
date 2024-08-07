## Represents the graph area which creates and connects MonologueGraphNodes.
class_name MonologueGraphEdit
extends GraphEdit


## Action queue history for undo/redo functionality.
var action_queue: ActionQueue = ActionQueue.new()
## Scene resource for the close button.
var close_button_scene = preload("res://Objects/SubComponents/CloseButton.tscn")
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
var control_node: MonologueControl
## Checks if a graphnode is currently selected.
var graphnode_selected = false

var mouse_pressed = false
var connecting_mode = false
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


## Adds a node of the given type to the current GraphEdit.
## If [param history] is true, record this action in GraphEdit history.
func add_node(node_type, history: bool = true) -> Array[MonologueGraphNode]:
	# get the correct Monologue node class from the given node_type
	var node_class = control_node.node_class_dictionary.get(node_type)
	# new_node is the node instance to be created
	var new_node = node_class.instance_from_type()
	# created_nodes include auxilliary nodes from new_node, such as BridgeOut
	var created_nodes: Array[MonologueGraphNode] = new_node.add_to_graph(self)
	
	# if enabled, track the addition of created_nodes into the graph history
	if history:
		var track_add = AddNodeHistory.new(self, created_nodes)
		action_queue.add(track_add)
	return created_nodes


## Centers the given graphnode or if [member control_node] is in picker mode,
## position and connect the newly created node from the picker.
func center_node(node: MonologueGraphNode):
	if control_node.picker_mode:
		var from_node = control_node.picker_from_node
		var from_port = control_node.picker_from_port
		disconnect_outbound_from_node(from_node, from_port)
		
		node.position_offset = control_node.picker_position
		propagate_connection(from_node, from_port, node.name, 0)
		control_node.disable_picker_mode()
	else:
		node.position_offset = ((size / 2) + scroll_offset) / zoom


## Disconnect all outbound connections of the given graphnode and port.
func disconnect_outbound_from_node(from_node: StringName, from_port: int):
	for connection in get_connection_list():
		if connection.get("from_node") == from_node:
			var to_node = connection.get("to_node")
			var to_port = connection.get("to_port")
			disconnect_node(from_node, from_port, to_node, to_port)


## Deletes the given graphnode and return its dictionary data.
func free_graphnode(node: MonologueGraphNode) -> Dictionary:
	var inbound_connections = get_all_inbound_connections(node.name)
	var outbound_connections = get_all_outbound_connections(node.name)
	
	for c in inbound_connections + outbound_connections:
		disconnect_node(c.get("from_node"), c.get("from_port"),
				c.get("to_node"), c.get("to_port"))
	
	# retrive node data before deletion, can be useful in some cases
	var node_data = node._to_dict()
	# tag options into the node_data without NextIDs
	if "options" in node:
		node_data.merge({"Options": node.options})
	
	node.queue_free()
	return node_data


## Find all other connections that connect to the given graphnode.
func get_all_inbound_connections(from_node: StringName):
	var connections = []
	for connection in get_connection_list():
		if connection.get("to_node") == from_node:
			connections.append(connection)
	return connections


## Find all connections that originate from the given graphnode.
func get_all_outbound_connections(from_node: StringName):
	var connections = []
	for connection in get_connection_list():
		if connection.get("from_node") == from_node:
			connections.append(connection)
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


## Checks and ensure graph is ready before triggering undo.
func trigger_undo():
	if not connecting_mode:
		action_queue.previous()


## Checks and ensure graph is ready before triggering redo.
func trigger_redo():
	if not connecting_mode:
		action_queue.next()


## Connects/disconnects and updates a given connection's NextID if possible.
## If [param next] is true, establish connection and propagate NextIDs.
## If it is false, destroy connection and clear all linked NextIDs.
func propagate_connection(from_node, from_port, to_node, to_port, next = true):
	if next:
		connect_node(from_node, from_port, to_node, to_port)
	else:
		disconnect_node(from_node, from_port, to_node, to_port)
	
	var graph_node = get_node_or_null(NodePath(from_node))
	if graph_node and graph_node.has_method("update_next_id"):
		var target = get_node(NodePath(to_node)) if next else null
		graph_node.update_next_id(from_port, target)


func _on_child_entered_tree(node: Node):
	if node is MonologueGraphNode and not node is RootNode:
		var node_header = node.get_children(true)[0]
		var close_button: TextureButton = close_button_scene.instantiate()
		
		var close_callback = func():
				# add to action history when close_button is pressed
				var delete_history = DeleteNodeHistory.new(self, [node])
				action_queue.add(delete_history)
				free_graphnode(node)
		
		close_button.connect("pressed", close_callback)
		node_header.add_child(close_button)


func _on_connection_drag_started(_from_node, _from_port, _is_output):
	connecting_mode = true


func _on_connection_drag_ended():
	connecting_mode = false


func _on_connection_request(from_node, from_port, to_node, to_port):
	# in Monologue, nodes can only have ONE outbound connection
	# so check to make sure there are no other connections before connecting
	if get_all_connections_from_slot(from_node, from_port).size() <= 0:
		var arguments = [from_node, from_port, to_node, to_port]
		var link = propagate_connection.bindv(arguments)
		var unlink = propagate_connection.bindv(arguments + [false])
		
		var history = ActionHistory.new(unlink, link)
		action_queue.add(history)
		connect.call()


func _on_disconnection_request(from_node, from_port, to_node, to_port):
	var arguments = [from_node, from_port, to_node, to_port]
	var link = propagate_connection.bindv(arguments)
	var unlink = propagate_connection.bindv(arguments + [false])
	
	var history = ActionHistory.new(link, unlink)
	action_queue.add(history)
	disconnect.call()


func _on_connection_to_empty(from_node, from_port, release_position):
	control_node.enable_picker_mode(from_node, from_port, release_position)


func _on_node_selected(node):
	active_graphnode = node
	graphnode_selected = true


func _on_node_deselected(_node):
	active_graphnode = null
	graphnode_selected = false
