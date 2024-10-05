@icon("res://Assets/Icons/NodesIcons/DiceRoll.svg")
class_name RandomNode extends MonologueGraphNode


@onready var output_line := preload("res://Objects/SubComponents/OutputLine.tscn")

var outputs := Property.new(LIST, { }, [])

var _output_references: Array = []


func _ready():
	node_type = "NodeRandom"
	super._ready()
	
	load_outputs(outputs.value)
	outputs.setters["add_callback"] = add_output
	outputs.setters["get_callback"] = get_outputs
	outputs.connect("preview", load_outputs)
	outputs.connect("preview", _update)
	_update()


func _load_connections(data: Dictionary, key: String = "PassID") -> void:
	super._load_connections(data, key)
	var fail_id = data.get("FailID")
	if fail_id is String:
		var fail_node = get_parent().get_node_by_id(fail_id)
		get_parent().connect_node(name, 1, fail_node.name, 0)


func _to_next(dict: Dictionary, key: String = "PassID") -> void:
	var pass_id_node = get_graph_edit().get_all_connections_from_slot(name, 0)
	dict[key] = pass_id_node[0].id.value if pass_id_node else -1
	
	var fail_id_node = get_graph_edit().get_all_connections_from_slot(name, 1)
	dict["FailID"] = fail_id_node[0].id.value if fail_id_node else -1


func add_output(data: Dictionary = {}) -> MonologueRandomOutput:
	var output = MonologueRandomOutput.new(self)
	if data:
		output._from_dict(data)
	output.id.value = _output_references.size()
	_output_references.append(output)
	
	var shared_weight = 100/_output_references.size()
	for idx in _output_references.size():
		_output_references[idx].weight.value = shared_weight
	
	return output


func get_outputs() -> Array:
	return _output_references


func load_outputs(new_output_list: Array):
	_output_references.clear()
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


func _update(new_value: Variant = null) -> void:
	for child in get_children():
		child.free()
	
	for output in _output_references:
		var idx: int = _output_references.bsearch(output)
		var output_ref := output_line.instantiate()
		add_child(output_ref)
		output_ref.update_label(str(output.weight.value) + "%")
	
	for idx in get_child_count():
		set_slot(idx, (idx==0), 0, Color.WHITE, true, 0, Color.WHITE, LEFT_ARROW_SLOT_TEXTURE, RIGHT_ARROW_SLOT_TEXTURE)
	
	super._update()
