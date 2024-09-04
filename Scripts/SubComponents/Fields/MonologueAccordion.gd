## Special field that will hide/show controls when selecting from dropdown.
class_name MonologueAccordion extends MonologueOptionButton


## Dictionary of group name as key and list of MonologueFields as values.
var control_groups: Dictionary = {}


func add_to_dict(dict: Dictionary) -> void:
	var control_list = control_groups.get(option_button.selected)
	var group_dict = {}
	for control in control_list:
		if control is MonologueField:
			group_dict[control.key] = control.value
	dict[key] = group_dict


func group(index: int, list: Array) -> MonologueField:
	control_groups[index] = list
	for control in list:
		panel.add_child(control)
		control.hide()
	return self


func set_value(new_value: Variant) -> void:
	super.set_value(new_value)
	show_selected()


func show_selected():
	for i in control_groups.keys():
		for control in control_groups.values()[i]:
			if i == option_button.selected:
				control.show()
			else:
				control.hide()
