## Character data builder.
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
	new_list[id.value]["Weight"] = new_value
	
	var weight_sum = 0
	for output in graph_node._output_references:
		weight_sum += output.weight.value
	
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
	return { "ID": id.value, "Weight": weight.value }
