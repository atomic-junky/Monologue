extends GraphEdit


var file_path: String

var speakers = []
var variables = []
var mouse_pressed = false
var selection_mode = false

var graphnode_selected = false
var moving_mode = false

func _input(event):
	if event is InputEventMouseButton:
		mouse_pressed = event.is_pressed()
	
	selection_mode = false
	moving_mode = false
	if event is InputEventMouseMotion and mouse_pressed:
		selection_mode = true
		moving_mode = graphnode_selected

func get_all_connections_from_node(from_node: StringName):
	var connections = []
	
	for connection in get_connection_list():
		if connection.get("from") == from_node:
			var to = get_node_or_null(NodePath(connection.get("to")))
			connections.append(to)

	return connections


func get_all_connections_from_slot(from_node: StringName, from_port: int):
	var connections = []
	
	for connection in get_connection_list():
		if connection.get("from") == from_node and connection.get("from_port") == from_port:
			var to = get_node_or_null(NodePath(connection.get("to")))
			connections.append(to)

	return connections


func clear_all_empty_connections():
	for co in get_connection_list():
		var to_name = co.get("to")
		var node_ref = get_node_or_null(NodePath(to_name))
		if node_ref == null or node_ref.is_queued_for_deletion():
			disconnect_node(co.get("from"), co.get("from_port"), co.get("to"), co.get("to_port"))

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
