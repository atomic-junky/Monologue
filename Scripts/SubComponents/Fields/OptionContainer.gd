## Previously known as ChoiceNodePanel. Represents UI for ChoiceNode options.
class_name OptionContainer extends MonologueField


var container: VBoxContainer
var option_data = []
var option_node = preload("res://Objects/SubComponents/OptionNode.tscn")


#
#func add_option():
	#var opt_panel = option_node.instantiate()
	#opt_panel.panel_node = self
	#opt_panel.graph_node = graph_node
	#
	#container.add_child(opt_panel)
	#opt_panel._from_dict(null)  # new id is generated on add, so update it
#
#
### Gets the _to_dict() data of all options in [member options_container].
#func get_options_data():
	#var data = []
	#for option in container.get_children():
		#if not option.is_queued_for_deletion():
			#data.append(option._to_dict())
	#return data
#
#
### Retrives a given option node by ID from [member options_container].
#func get_option_node(option_id: String):
	#for node in container.get_children():
		#if node.id == option_id:
			#return node
#
#
#func reload_options():
	#for child in container.get_children():
		#child.queue_free()
	#
	#for option in option_data:
		#var opt_panel = option_node.instantiate()
		#opt_panel.panel_node = self
		#opt_panel.graph_node = graph_node
		#
		#container.add_child(opt_panel)
		#opt_panel._from_dict(option)
#
#
### Adds latest option data changes into graph history, if any.
#func save_options():
	#_on_node_property_change(["options"], [get_options_data()])
	#change.emit(self)
#
#
### Update GUI for options list.
#func update_options():
	#for i in graph_node.options.size():
		#options_container.get_child(i)._from_dict(graph_node.options[i])
#
#
#func _on_add_option_pressed():
	#add_option()
	#save_options()
