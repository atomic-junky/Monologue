## Random output data builder.
class_name MonologueRandomOutput extends RefCounted


var weight := Property.new(MonologueGraphNode.SPINBOX, { "minimum": 0, "maximum": 100 })
var id     := Property.new(MonologueGraphNode.SPINBOX)


var graph: MonologueGraphEdit
var graph_node: RandomNode


func _init(node: RandomNode):
	graph_node = node
	graph = node.get_parent()
	weight.connect("change", change_output_weight)
	id.visible = false


func change_output_weight(old_value: Variant, new_value: Variant):
	var old_list = graph_node.outputs.value.duplicate(true)
	var new_list = graph_node.outputs.value.duplicate(true)
	
	# new value cannot push total weight to exceed 100
	var clamped = clampi(new_value, 1, 100 - new_list.size() + 1)
	new_list[id.value]["Weight"] = clamped
	
	# make up for missing weight by balancing from next
	var weight_sum = new_list.reduce(func(total, n): return total + n.get("Weight"), 0)
	var balance = 100 - weight_sum
	var count = 1
	while count < new_list.size() and balance != 0:
		var i = (id.value + count) % new_list.size()
		var new_weight = new_list[i].get("Weight") + balance
		if new_weight < 1:
			balance -= new_list[i].get("Weight") - 1
			new_weight = 1
		else:
			balance = 0
		new_list[i]["Weight"] = new_weight
		count += 1
	
	graph.undo_redo.create_action("RandomOutput %s => %s" % [old_value, new_value])
	graph.undo_redo.add_do_property(graph_node.outputs, "value", new_list)
	graph.undo_redo.add_do_method(graph_node.outputs.propagate.bind(new_list))
	graph.undo_redo.add_undo_property(graph_node.outputs, "value", old_list)
	graph.undo_redo.add_undo_method(graph_node.outputs.propagate.bind(old_list))
	graph.undo_redo.commit_action()


func get_property_names() -> PackedStringArray:
	return ["weight"]


func _from_dict(dict: Dictionary) -> void:
	id.value = dict.get("ID")
	weight.value = dict.get("Weight")


func _to_dict():
	var next_id_node = graph.get_all_connections_from_slot(graph_node.name, id.value)
	return { "ID": id.value, "Weight": weight.value, "NextID": next_id_node[0].id.value if next_id_node else -1 }
