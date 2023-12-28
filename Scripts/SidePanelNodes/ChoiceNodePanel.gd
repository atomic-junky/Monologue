@icon("res://Assets/Icons/NodesIcons/Multiple Choice.svg")

class_name ChoiceNodePanel

extends MonologueNodePanel

const arrow_texture01 = preload("res://Assets/Icons/NodesIcons/Arrow01.svg")
const arrow_texture02 = preload("res://Assets/Icons/NodesIcons/Arrow02.svg")

@onready var option_panel = preload("res://Objects/SubComponents/OptionNode.tscn")
@onready var options_container = $OptionsContainer


func _from_dict(dict):
	id = dict.get("ID")
	
	for option in graph_node.options:
		var opt_panel = option_panel.instantiate()
		opt_panel.panel_node = self
		opt_panel.graph_node = graph_node
		
		options_container.add_child(opt_panel)
		opt_panel._from_dict(option)
	
	change.emit(self)


func new_option():
	var option = option_panel.instantiate()
	option.panel_node = self
	option.graph_node = graph_node
	
	options_container.add_child(option)
	option.update_ref()


func _on_add_option_pressed():
	new_option()
