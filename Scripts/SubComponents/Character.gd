## Character data builder.
class_name Character extends RefCounted


var name  := Property.new(MonologueGraphNode.LINE)
var id    := Property.new(MonologueGraphNode.SPINBOX)

var graph: MonologueGraphEdit
var root: RootNode


func _init(node: RootNode):
	root = node
	graph = node.get_parent()
	name.connect("change", change_character_name)
	name.connect("display", graph.set_selected.bind(root))
	id.visible = false


func change_character_name(old_value: Variant, new_value: Variant):
	var old_list = root.speakers.value.duplicate(true)
	var new_list = root.speakers.value.duplicate(true)
	new_list[id.value]["Reference"] = new_value
	
	graph.undo_redo.create_action("Character %s => %s" % [old_value, new_value])
	graph.undo_redo.add_do_property(root.speakers, "value", new_list)
	graph.undo_redo.add_do_method(root.speakers.propagate.bind(new_list))
	graph.undo_redo.add_undo_property(root.speakers, "value", old_list)
	graph.undo_redo.add_undo_method(root.speakers.propagate.bind(old_list))
	graph.undo_redo.commit_action()


func get_property_names() -> PackedStringArray:
	return ["name"]


func _from_dict(dict: Dictionary) -> void:
	name.value = dict.get("Reference")
	id.value = dict.get("ID")


func _to_dict():
	return { "Reference": name.value, "ID": id.value }
