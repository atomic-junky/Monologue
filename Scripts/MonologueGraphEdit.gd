## Represents the graph area which creates and connects MonologueGraphNodes.
class_name MonologueGraphEdit
extends GraphEdit


var close_button_scene = preload("res://Objects/SubComponents/CloseButton.tscn")
var control_node: MonologueControl
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

var mouse_hovering: bool = false


func _ready():
	var auto_arrange_button = get_menu_hbox().get_children().back()
	auto_arrange_button.connect("pressed", _on_auto_arrange_nodes)
	
	center_offset.bindv([true]).call_deferred()
	
	# Hide scroll bar
	for child in get_children(true):
		if child is GraphNode:
			continue
		
		for subchild in child.get_children(true):
			if subchild is not ScrollBar:
				continue
				
			for sb_name in ["grabber", "scroll"]:
				subchild.add_theme_stylebox_override(sb_name, StyleBoxEmpty.new())


func _on_add_btn() -> void:
	GlobalSignal.emit("select_new_node")


func center_offset(to_root: bool = false):
	var base_offset = Vector2.ZERO
	if to_root:
		var root_node: RootNode = get_root_node()
		base_offset = root_node.position_offset + (root_node.size/2)*zoom
	
	scroll_offset = -size/2 + base_offset


func get_root_node() -> RootNode:
	var root_node: RootNode
	for node in get_nodes():
		if node is RootNode:
			root_node = node
	
	return root_node


func _input(event):
	if event.is_action_pressed("ui_graph_delete") and \
			!control_node.side_panel_node.visible and !active_graphnode and \
			control_node.get_current_graph_edit() == self and selected_nodes:
		var selected_copy = selected_nodes.duplicate()
		var delete_history = DeleteNodeHistory.new(self, selected_copy)
		undo_redo.create_action("Delete %s" % str(selected_copy))
		undo_redo.add_prepared_history(delete_history)
		undo_redo.commit_action()
		return
	
	var is_mouse_clicked = Input.is_action_pressed("Select")
	var is_mouse_moving = event is InputEventMouseMotion
	var is_node_selected = not selected_nodes.is_empty()
	
	moving_mode = is_mouse_clicked and is_mouse_moving and is_node_selected


func _gui_input(event: InputEvent) -> void:
	if not mouse_hovering:
		return
	
	if Input.is_action_pressed("Spacebar"):
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			Cursor.shape = Cursor.Shapes.CURSOR_HAND_CLOSED
		else:
			Cursor.shape = Cursor.Shapes.CURSOR_DRAG
	
	if Input.is_action_just_released("Spacebar"):
		Cursor.shape = CURSOR_ARROW


## Adds a node of the given type to this graph.
func add_node(node_type, record: bool = true) -> Array[MonologueGraphNode]:
	# if adding from picker, track existing to_nodes of the picker_from_node
	var picker_to_names = []
	if control_node.picker_from_node and control_node.picker_from_port:
		for picker_to_node in get_all_connections_from_slot(
				control_node.picker_from_node, control_node.picker_from_port):
			picker_to_names.append(picker_to_node.name)
	
	var node_scene = control_node.scene_dictionary.get(node_type)
	var new_node = node_scene.instantiate()
	
	# created_nodes include auxilliary nodes from new_node, such as BridgeOut
	var created_nodes = new_node.add_to(self)
	pick_and_center(created_nodes)
	
	# if enabled, track the addition of created_nodes into the graph history
	if record:
		var addition = AddNodeHistory.new(self, created_nodes)
		if not picker_to_names.is_empty():
			addition.picker_from_node = control_node.picker_from_node
			addition.picker_from_port = control_node.picker_from_port
			addition.picker_to_names = picker_to_names
		
		undo_redo.create_action("Add new %s" % [new_node.node_type])
		undo_redo.add_prepared_history(addition)
		undo_redo.commit_action(false)
	
	return created_nodes


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
	
	var node_data = node._to_dict()
	if "options" in node:
		# tag options into the node_data without NextIDs
		node_data.merge({ "Options": node.options })
	
	if active_graphnode == node:
		active_graphnode = null
	selected_nodes.erase(node)
	recorded_positions.erase(node)
	node.queue_free()
	
	# if side panel is showing this node, close it since it's gone
	var side_panel = control_node.side_panel_node
	var current_panel = side_panel.current_panel
	if current_panel and current_panel.graph_node == node:
		side_panel.clear_current_panel()
		side_panel.hide()
	
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
func get_all_connections_from_slot(from_node: StringName, from_port: int):
	var connections = []
	for connection in get_connection_list():
		if connection.get("from_node") == from_node and connection.get("from_port") == from_port:
			var to = get_node_or_null(NodePath(connection.get("to_node")))
			connections.append(to)
	return connections


func get_free_bridge_number(_n=1, lp_max=50):
	for node in get_nodes():
		if (node.node_type == "NodeBridgeOut" or node.node_type == "NodeBridgeIn") and node.number_selector.value == _n:
			if lp_max <= 0:
				return _n
				
			return get_free_bridge_number(_n+1, lp_max-1)
	return _n


func get_linked_bridge_node(target_number):
	for node in get_nodes():
		if node.node_type == "NodeBridgeOut" and node.number_selector.value == target_number:
			return node


func get_node_by_id(id: String) -> MonologueGraphNode:
	for node in get_nodes():
		if node.id == id:
			return node
	return null


## Check if an option ID exists in the entirety of the graph.
func is_option_id_exists(option_id: String):
	for node in get_nodes():
		if node.node_type != "NodeChoice":
			continue
		var node_options_id: Array = node.get_all_options_id()
		if node_options_id.has(option_id):
			return true
	return false


func is_unsaved():
	return version != undo_redo.get_version()


## Connect picker_from_node to [param node] if needed, reposition nodes.
func pick_and_center(nodes: Array[MonologueGraphNode]):
	var offset = ((size / 2) + scroll_offset) / zoom  # center of graph
	if control_node.picker_from_node != null and control_node.picker_from_port != null:
		var from_node = control_node.picker_from_node
		var from_port = control_node.picker_from_port
		disconnect_outbound_from_node(from_node, from_port)
		propagate_connection(from_node, from_port, nodes[0].name, 0)
		control_node.disable_picker_mode()
		offset = control_node.picker_position
		
		control_node.picker_from_node = null
		control_node.picker_from_port = null
	
	for node in nodes:
		node.position_offset = offset - node.size / 2
		offset += Vector2(node.size.x + 10, 0)


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
		if next:
			var next_node = get_node_or_null(NodePath(to_node))
			graph_node.update_next_id(from_port, next_node)
		else:
			graph_node.update_next_id(from_port, null)


## Checks and ensure graph is ready before triggering undo.
func trigger_undo():
	if not connecting_mode:
		undo_redo.undo()


## Checks and ensure graph is ready before triggering redo.
func trigger_redo():
	if not connecting_mode:
		undo_redo.redo()


func update_node_positions() -> void:
	var affected_nodes = selected_nodes if selected_nodes else get_nodes()
	for node in affected_nodes:
		recorded_positions[node] = node.position_offset


func update_version():
	version = undo_redo.get_version()


func _on_auto_arrange_nodes():
	var affected = selected_nodes if selected_nodes else get_nodes()
	var changed = affected.filter(func(n): return n.position_offset != recorded_positions[n])
	if changed and affected.size() > 1:
		undo_redo.create_action("Auto arrange nodes")
		for node in changed:
			undo_redo.add_do_property(node, "position_offset", node.position_offset)
			undo_redo.add_undo_property(node, "position_offset", recorded_positions[node])
		undo_redo.commit_action(false)
		update_node_positions()


func _on_child_entered_tree(node: Node):
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


func _on_connection_drag_started(_from_node, _from_port, _is_output):
	connecting_mode = true


func _on_connection_drag_ended():
	connecting_mode = false


func _on_connection_request(from_node, from_port, to_node, to_port):
	# so check to make sure there are no other connections before connecting
	if get_all_connections_from_slot(from_node, from_port).size() <= 0:
		var arguments = [from_node, from_port, to_node, to_port]
		var message = "Connect %s port %d to %s port %d"
		undo_redo.create_action(message % arguments)
		undo_redo.add_do_method(propagate_connection.bindv(arguments))
		undo_redo.add_undo_method(propagate_connection.bindv(arguments + [false]))
		undo_redo.commit_action()


func _on_disconnection_request(from_node, from_port, to_node, to_port):
	var arguments = [from_node, from_port, to_node, to_port]
	var message = "Disconnect %s from %s port %d"
	undo_redo.create_action(message % [to_node, from_node, from_port])
	undo_redo.add_do_method(propagate_connection.bindv(arguments + [false]))
	undo_redo.add_undo_method(propagate_connection.bindv(arguments))
	undo_redo.commit_action()


func _on_connection_to_empty(from_node, from_port, release_position):
	if control_node:
		control_node.enable_picker_mode(from_node, from_port, release_position)


func _on_node_selected(node):
	if node is MonologueGraphNode:
		selected_nodes.append(node)


func _on_node_deselected(node):
	recorded_positions[node] = node.position_offset
	selected_nodes.erase(node)
	active_graphnode = null  # when a deselection happens, clear active node


func get_nodes() -> Array[MonologueGraphNode]:
	var list: Array[MonologueGraphNode] = []
	for node in get_children():
		if node is MonologueGraphNode:
			list.append(node)
	return list


func _on_mouse_entered() -> void:
	mouse_hovering = true


func _on_mouse_exited() -> void:
	Cursor.shape = CURSOR_ARROW
	mouse_hovering = false
