@icon("res://ui/assets/icons/dice.svg")
class_name RandomNode extends MonologueGraphNode
# FIXME: RandomNode is broken, connections doesn't work and changing the value of a field makes the program crash.


@onready var output_line := preload("res://nodes/random_node/output_line.tscn")

var outputs := Property.new(LIST, { }, [])

var _output_references: Array = []


func _ready():
	node_type = "NodeRandom"
	super._ready()
	
	outputs.setters["add_callback"] = add_output
	outputs.setters["delete_callback"] = modify_on_delete
	outputs.setters["get_callback"] = get_outputs
	outputs.connect("preview", _refresh)
	
	if outputs.value.size() <= 0:
		load_outputs([])
		_refresh(outputs.value)


func _from_dict(dict: Dictionary) -> void:
	# check for backwards compatibility v2.x
	if dict.has("Target"):
		var target = dict.get("Target", 0)
		var pass_output = {
			"ID": 0,
			"Weight": target,
			"NextID": dict.get("PassID")
		}
		var fail_output = {
			"ID": 1,
			"Weight": 100 - target,
			"NextID": dict.get("FailID")
		}
		dict["Outputs"] = [pass_output, fail_output]
	
	load_outputs(dict.get("Outputs", []))
	_load_position(dict)
	_update()


func _to_next(_dict: Dictionary, _key: String = "NextID") -> void:
	pass


func add_output(data: Dictionary = {}) -> MonologueRandomOutput:
	var output = MonologueRandomOutput.new(self)
	output.id.value = _output_references.size()
	if data:
		output._from_dict(data)
		var next_id = data.get("NextID", -1)
		if next_id is String:
			var next_node = get_parent().get_node_by_id(next_id)
			if next_node:
				get_parent().connect_node(name, data.get("ID", output.id.value), next_node.name, 0)
		
	_output_references.append(output)
	var line_instance := output_line.instantiate()
	add_child(line_instance)
	line_instance.update_label(str(output.weight.value) + "%")
	
	# if output was added from scratch, redistribute all equally
	if not data:
		var share = 100.0 / _output_references.size()
		for idx in range(_output_references.size()):
			var weight = ceil(share) if idx == 0 else floor(share)
			_output_references[idx].weight.value = weight
		
		var refs = _output_references.slice(0, _output_references.size() - 1)
		var dicts = refs.map(func(r): return r._to_dict())
		outputs.propagate(dicts)
	
	return output


func clear_children() -> void:
	for child in get_children():
		child.free()
	_output_references.clear()


func get_outputs() -> Array:
	return _output_references


func load_outputs(new_output_list: Array):
	clear_children()
	var ascending = func(a, b): return a.get("ID") < b.get("ID")
	new_output_list.sort_custom(ascending)
	for output_data in new_output_list:
		add_output(output_data)
	
	if _output_references.is_empty():
		var first = add_output()
		var second = add_output()
		first.weight.value = 50
		second.weight.value = 50
		new_output_list.append(first._to_dict())
		new_output_list.append(second._to_dict())
	outputs.value = new_output_list


func modify_on_delete(data_list: Array):
	if data_list:
		# reassign IDs on delete
		for i in range(data_list.size()):
			data_list[i]["ID"] = i
		
		# rebalance weights if the sum is not equal to 100
		var weights = data_list.map(func(d): return d.get("Weight"))
		var sum = weights.reduce(func(total, w): return total + w)
		if sum != 100:
			var share = 100.0 / data_list.size()
			for idx in range(data_list.size()):
				var weight = ceil(share) if idx == 0 else floor(share)
				data_list[idx]["Weight"] = weight
	return data_list


## Update the NextID of the output on the given port.
func update_next_id(from_port: int, next_node: MonologueGraphNode):
	var output = _output_references[from_port]
	var next_value = -1
	if next_node:
		next_value = next_node.id.value
	output.next_id.value = next_value
	outputs.value[from_port] = output._to_dict()
	outputs.propagate(outputs.value, false)


func _refresh(new_outputs_list: Array):
	# disconnect all outbound connections
	for connection in get_parent().get_all_outbound_connections(name):
		var from_port = connection.get("from_port")
		var to_node = connection.get("to_node")
		get_parent().disconnect_node(name, from_port, to_node, 0)
	clear_children()
	
	for new_output_data in new_outputs_list:
		add_output(new_output_data)
	_update()


func _update(_new_value: Variant = null) -> void:
	for idx in get_child_count():
		set_slot(idx, (idx==0), 0, Color.WHITE, true, 0, Color.WHITE, LEFT_SLOT, RIGHT_SLOT)
	super._update()
