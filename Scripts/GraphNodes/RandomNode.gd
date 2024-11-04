@icon("res://Assets/Icons/NodesIcons/DiceRoll.svg")
class_name RandomNode extends MonologueGraphNode
# FIXME: RandomNode is broken, connections doesn't work and changing the value of a field makes the program crash.


@onready var output_line := preload("res://Objects/SubComponents/OutputLine.tscn")

var outputs := Property.new(LIST, { }, [])

var _output_references: Array = []


func _ready():
	node_type = "NodeRandom"
	super._ready()
	
	outputs.setters["add_callback"] = add_output
	outputs.setters["get_callback"] = get_outputs
	outputs.connect("preview", _update)
	
	if outputs.value.size() <= 0:
		add_output()
		add_output()
	
	_update()


func _from_dict(dict: Dictionary) -> void:
	super._from_dict(dict)
	load_outputs(outputs.value)
	_update()


func _load_connections(data: Dictionary, key: String = "NextID") -> void:
	for output in data.get("Outputs"):
		var next_id = output.get(key)
		if next_id is String:
			var next_node = get_parent().get_node_by_id(next_id)
			get_parent().connect_node(name, output["ID"], next_node.name, 0)


func _to_next(_dict: Dictionary, _key: String = "NextID") -> void:
	pass


func add_output(data: Dictionary = {}) -> MonologueRandomOutput:
	var output = MonologueRandomOutput.new(self)
	output.id.value = _output_references.size()
	if data:
		output._from_dict(data)
	_output_references.append(output)
	
	if not data:  # if output was added from scratch, redistribute all equally
		var share = 100.0 / _output_references.size()
		for idx in range(_output_references.size()):
			var weight = ceil(share) if idx == 0 else floor(share)
			_output_references[idx].weight.value = weight
		
		var refs = _output_references.slice(0, _output_references.size() - 1)
		var dicts = refs.map(func(r): return r._to_dict())
		outputs.propagate(dicts)
	
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
		new_output_list.append(first._to_dict())
		new_output_list.append(second._to_dict())
	outputs.value = new_output_list


func _update(_new_value: Variant = null) -> void:
	for child in get_children():
		child.free()
	
	for output in _output_references:
		var output_ref := output_line.instantiate()
		add_child(output_ref)
		output_ref.update_label(str(output.weight.value) + "%")
	
	for idx in get_child_count():
		set_slot(idx, (idx==0), 0, Color.WHITE, true, 0, Color.WHITE, LEFT_ARROW_SLOT_TEXTURE, RIGHT_ARROW_SLOT_TEXTURE)
	
	super._update()
