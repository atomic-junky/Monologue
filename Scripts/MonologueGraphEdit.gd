## Represents the graph area which creates and connects MonologueGraphNodes.
class_name MonologueGraphEdit
extends GraphEdit


var close_button_scene = preload("res://Objects/SubComponents/CloseButton.tscn")
var data: Dictionary
var file_path: String
var undo_redo := HistoryHandler.new()
var version = undo_redo.get_version()

var speakers = []
var variables = []

var active_graphnode: MonologueGraphNode  # for tab-switching purpose
var connecting_mode: bool
var moving_mode: bool
var recorded_positions: Dictionary = {}  # for undo/redo positoning purpose
var selected_nodes: Array[MonologueGraphNode] = []  # for group delete


func _ready() -> void:
	var auto_arrange_button = get_menu_hbox().get_children().back()
	auto_arrange_button.connect("pressed", _on_auto_arrange_nodes)


func _input(event: InputEvent) -> void:
	moving_mode = Input.is_action_pressed("Select") and \
			event is InputEventMouseMotion and not selected_nodes.is_empty()


## Adds a node of the given type to this graph.
func add_node(node_type: String, record_history: bool = true,
			picker: GraphNodeSelector = null) -> Array[MonologueGraphNode]:
	var node_scene = GlobalVariables.node_dictionary.get(node_type)
	var new_node = node_scene.instantiate()
	
	# created_nodes include auxilliary nodes from new_node, such as BridgeOut
	var created_nodes = new_node.add_to(self)
	var picker_to_names = pick_and_center(created_nodes, picker)
	
	# if enabled, track the addition of created_nodes into the graph history
	if record_history:
		var addition = AddNodeHistory.new(self, created_nodes)
		if not picker_to_names.is_empty():
			addition.picker_from_node = picker.node
			addition.picker_from_port = picker.port
			addition.picker_to_names = picker_to_names
		
		undo_redo.create_action("Add new %s" % [new_node.node_type])
		undo_redo.add_prepared_history(addition)
		undo_redo.commit_action(false)
	
	return created_nodes


func clear():
	for node in get_nodes():
		node.queue_free()
	clear_connections()


## Disconnect all outbound connections of the given graphnode and port.
func disconnect_outbound_from_node(from_node: StringName, from_port: int) -> void:
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
	
	var node_data = node._to_dict()
	if "options" in node:
		# tag options into the node_data without NextIDs
		node_data.merge({"Options": node.options})
	if active_graphnode == node:
		active_graphnode = null
	
	selected_nodes.erase(node)
	recorded_positions.erase(node)
	node.queue_free()
	# if side panel is showing this node, close it since it's gone
	GlobalSignal.emit("clear_current_panel", [node])
	return node_data


## Find all other connections that connect to the given graphnode.
func get_all_inbound_connections(from_node: StringName) -> Array:
	var connections = []
	for connection in get_connection_list():
		if connection.get("to_node") == from_node:
			connections.append(connection)
	return connections


## Find all connections that originate from the given graphnode.
func get_all_outbound_connections(from_node: StringName) -> Array:
	var connections = []
	for connection in get_connection_list():
		if connection.get("from_node") == from_node:
			connections.append(connection)
	return connections


## Find connections of the given [param from_node] at its [param from_port].
func get_all_connections_from_slot(from_node: StringName, from_port: int) -> Array:
	var connections = []
	for connection in get_connection_list():
		if connection.get("from_node") == from_node and connection.get("from_port") == from_port:
			var to = get_node_or_null(NodePath(connection.get("to_node")))
			connections.append(to)
	return connections


func get_free_bridge_number(_n=1, lp_max=50) -> int:
	for node in get_nodes():
		if (node.node_type == "NodeBridgeOut" or node.node_type == "NodeBridgeIn") and node.number_selector.value == _n:
			if lp_max <= 0:
				return _n
				
			return get_free_bridge_number(_n+1, lp_max-1)
	return _n


func get_linked_bridge_node(target_number) -> MonologueGraphNode:
	for node in get_nodes():
		if node.node_type == "NodeBridgeOut" and node.number_selector.value == target_number:
			return node
	return null


func get_root_node() -> RootNode:
	for node in get_nodes():
		if node is RootNode:
			return node
	return null


## Find a graph node by ID. Includes NodeOption embedded in NodeChoice.
func get_node_by_id(id: String) -> MonologueGraphNode:
	if not id.is_empty():
		for node in get_nodes():
			if node.id == id:
				return node
			elif node.node_type == "NodeChoice" and node.option_nodes.get(id):
				return node.option_nodes.get(id)
	return null


func is_unsaved() -> bool:
	return version != undo_redo.get_version()


## Connect picker_from_node to [param node] if needed, reposition nodes.
func pick_and_center(nodes: Array[MonologueGraphNode], 
			picker: GraphNodeSelector) -> PackedStringArray:
	var to_names = []
	var offset = ((size / 2) + scroll_offset) / zoom  # center of graph
	if picker:  # if adding from picker, track existing to_nodes from picker
		for to_node in get_all_connections_from_slot(picker.node, picker.port):
			to_names.append(to_node.name)
		disconnect_outbound_from_node(picker.node, picker.port)
		propagate_connection(picker.node, picker.port, nodes[0].name, 0)
		GlobalSignal.emit("disable_picker_mode")
		offset = picker.location
	
	for node in nodes:
		node.position_offset = offset - node.size / 2
		offset += Vector2(node.size.x + 10, 0)
	return to_names


## Connects/disconnects and updates a given connection's NextID if possible.
## If [param next] is true, establish connection and propagate NextIDs.
## If it is false, destroy connection and clear all linked NextIDs.
func propagate_connection(from_node, from_port, to_node, to_port, next = true) -> void:
	if next:
		connect_node(from_node, from_port, to_node, to_port)
	else:
		disconnect_node(from_node, from_port, to_node, to_port)
	
	var graph_node = get_node_or_null(NodePath(from_node))
	if graph_node and graph_node.has_method("update_next_id"):
		if next:
			var next_node = get_node_or_null(NodePath(to_node))
			graph_node.update_next_id(from_port, next_node)
		else:
			graph_node.update_next_id(from_port, null)


func trigger_delete():
	if not active_graphnode and selected_nodes:
		var root_filter = func(n): return n is not RootNode
		var selected_copy = selected_nodes.duplicate().filter(root_filter)
		var delete_history = DeleteNodeHistory.new(self, selected_copy)
		undo_redo.create_action("Delete %s" % str(selected_copy))
		undo_redo.add_prepared_history(delete_history)
		undo_redo.commit_action()


## Checks and ensure graph is ready before triggering undo.
func trigger_undo() -> void:
	if not connecting_mode:
		undo_redo.undo()


## Checks and ensure graph is ready before triggering redo.
func trigger_redo() -> void:
	if not connecting_mode:
		undo_redo.redo()


func update_node_positions() -> void:
	var affected_nodes = selected_nodes if selected_nodes else get_nodes()
	for node in affected_nodes:
		recorded_positions[node] = node.position_offset


func update_version() -> void:
	version = undo_redo.get_version()


func _on_auto_arrange_nodes() -> void:
	var affected = selected_nodes if selected_nodes else get_nodes()
	var changed = affected.filter(func(n): return n.position_offset != recorded_positions[n])
	if changed and affected.size() > 1:
		undo_redo.create_action("Auto arrange nodes")
		for node in changed:
			undo_redo.add_do_property(node, "position_offset", node.position_offset)
			undo_redo.add_undo_property(node, "position_offset", recorded_positions[node])
		undo_redo.commit_action(false)
		update_node_positions()


func _on_child_entered_tree(node: Node) -> void:
	if node is MonologueGraphNode and not node is RootNode:
		var node_header = node.get_children(true)[0]
		var close_button: TextureButton = close_button_scene.instantiate()
		
		var close_callback = func():
				var delete_history = DeleteNodeHistory.new(self, [node])
				var message = "Delete %s (id: %s)"
				undo_redo.create_action(message % [node.node_type, node.id])
				undo_redo.add_prepared_history(delete_history)
				undo_redo.commit_action(false)
				selected_nodes.erase(node)
				recorded_positions.erase(node)
				free_graphnode(node)
		
		close_button.connect("pressed", close_callback)
		node_header.add_child(close_button)


func _on_connection_drag_started(_from_node, _from_port, _is_output) -> void:
	connecting_mode = true


func _on_connection_drag_ended() -> void:
	connecting_mode = false


func _on_connection_request(from_node, from_port, to_node, to_port) -> void:
	# so check to make sure there are no other connections before connecting
	if get_all_connections_from_slot(from_node, from_port).size() <= 0:
		var arguments = [from_node, from_port, to_node, to_port]
		var message = "Connect %s port %d to %s port %d"
		undo_redo.create_action(message % arguments)
		undo_redo.add_do_method(propagate_connection.bindv(arguments))
		undo_redo.add_undo_method(propagate_connection.bindv(arguments + [false]))
		undo_redo.commit_action()


func _on_disconnection_request(from_node, from_port, to_node, to_port) -> void:
	var arguments = [from_node, from_port, to_node, to_port]
	var message = "Disconnect %s from %s port %d"
	undo_redo.create_action(message % [to_node, from_node, from_port])
	undo_redo.add_do_method(propagate_connection.bindv(arguments + [false]))
	undo_redo.add_undo_method(propagate_connection.bindv(arguments))
	undo_redo.commit_action()


func _on_connection_to_empty(node: String, port: int, release: Vector2) -> void:
	var center = (get_local_mouse_position() + scroll_offset) / zoom
	GlobalSignal.emit("enable_picker_mode", [node, port, release, center])


func _on_node_selected(node) -> void:
	if node is MonologueGraphNode:
		selected_nodes.append(node)


func _on_node_deselected(node) -> void:
	recorded_positions[node] = node.position_offset
	selected_nodes.erase(node)
	active_graphnode = null  # when a deselection happens, clear active node


func get_nodes() -> Array[MonologueGraphNode]:
	var list: Array[MonologueGraphNode] = []
	for node in get_children():
		if node is MonologueGraphNode:
			list.append(node)
	return list
