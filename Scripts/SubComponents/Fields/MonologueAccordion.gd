## Special field that will hide/show controls when selecting from dropdown.
class_name MonologueAccordion extends MonologueOptionButton


## Dictionary of group index as key and list of MonologueFields as values.
var control_groups: Dictionary = {}


func add_to_dict(dict: Dictionary) -> void:
	var control_list = control_groups.get(option_button.selected)
	var group_dict = {}
	for control in control_list:
		if control is MonologueField:
			group_dict[control.json_key] = control.value
	dict[json_key] = group_dict


func group(index: int, list: Array) -> MonologueField:
	control_groups[index] = list
	for control in list:
		connect("ready", func(): _add_to_panel_deferred(control))
		control.hide()
	return self


func set_value(new_value: Variant) -> void:
	super.set_value(new_value)
	if option_button:
		show_controls(option_button.selected)


func show_controls(group_index: int):
	for i in control_groups.keys():
		for control in control_groups.values()[i]:
			if i == group_index:
				control.show()
			else:
				control.hide()


## Callback to allow node_panel to be set by others before _ready().
func _add_to_panel_deferred(control: Node):
	if control is MonologueField:
		control.set_panel(panel)
	panel.add_child.call_deferred(control)
