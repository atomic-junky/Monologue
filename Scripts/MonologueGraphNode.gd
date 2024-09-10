## Abstract graph node class for Monologue dialogue nodes. This should not
## be used on its own, it should be overridden to replace [member node_type].
class_name MonologueGraphNode extends GraphNode


@export var titlebar_color: Color = Color("ff0000") : set = _set_titlebar_color


var id: String = UUID.v4()
var node_type: String = "NodeUnknown"


func _ready() -> void:
	_set_titlebar_color(titlebar_color)


func _set_titlebar_color(val: Color):
	var is_dark = val.get_luminance() < 0.5
	var stylebox: StyleBoxFlat = get_theme_stylebox("titlebar", "GraphNode").duplicate()
	stylebox.bg_color = val
	stylebox.corner_radius_top_left = 5
	stylebox.corner_radius_top_right = 5
	
	stylebox.border_color = Color("4d4d4d")
	stylebox.set_border_width_all(1)
	stylebox.border_width_bottom = 0
	
	var stylebox_selected = stylebox.duplicate()
	stylebox_selected.border_color = Color("b2b2b2")
	
	remove_theme_stylebox_override("titlebar")
	remove_theme_stylebox_override("titlebar_selected")
	add_theme_stylebox_override("titlebar", stylebox)
	add_theme_stylebox_override("titlebar_selected", stylebox_selected)
	
	var titlebar: HBoxContainer = get_titlebar_hbox()
	var title_label: Label = titlebar.get_children().filter(func(c) -> bool: return c is Label)[0]
	title_label.add_theme_color_override("font_color", Color.WHITE if is_dark else Color.BLACK)


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
