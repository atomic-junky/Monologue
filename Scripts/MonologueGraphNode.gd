## Abstract graph node class for Monologue dialogue nodes. This should not
## be used on its own, it should be overridden to replace [member node_type].
class_name MonologueGraphNode extends GraphNode


@export var titlebar_color: Color = Color(0.1294, 0.149, 0.1804, 1) : set = _set_titlebar_color


var id: String = UUID.v4()
var node_type: String = "NodeUnknown"


func _ready() -> void:
	_set_titlebar_color(titlebar_color)


func _set_titlebar_color(val: Color):
	var stylebox: StyleBoxFlat = get_theme_stylebox("titlebar", "GraphNode").duplicate()
	stylebox.bg_color = val
	
	remove_theme_stylebox_override("titlebar")
	add_theme_stylebox_override("titlebar", stylebox)


func add_to(graph) -> Array[MonologueGraphNode]:
	graph.add_child(self, true)
	return [self]


func _from_dict(_dict: Dictionary):
	pass


func _to_dict():
	pass


func _update(_panel = null):
	pass


func _common_update(_panel = null):
	size.y = 0
	
	if _panel:
		id = _panel.id


func _connect_to_panel(sgnl):
	sgnl.connect(_update)
	sgnl.connect(_common_update)
