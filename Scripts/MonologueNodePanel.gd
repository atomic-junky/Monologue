class_name MonologueNodePanel

extends VBoxContainer

signal change(panel)


var graph_node: MonologueGraphNode = null : set = _set_gn
var id

func _ready():
	pass

func _from_dict(_dict: Dictionary):
	pass

func _set_gn(new_gn):
	graph_node = new_gn
	graph_node._connect_to_panel(change)
