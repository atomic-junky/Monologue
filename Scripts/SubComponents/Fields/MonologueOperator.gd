class_name MonologueOperator extends MonologueOptionButton


const MATHS = { "list": ["=", "+", "-", "*", "/"], "blocked": [1, 2, 3, 4] }
const BOOLS = { "list": ["==", ">=", "<=", "!="], "blocked": [1, 2] }

var variable: MonologueOptionButton
var operator_set: Dictionary = {}
var option_list: Array[Dictionary] = []


func _init(property_name: String, dict_value: Variant, ops: Dictionary):
	super(property_name, "Operator", dict_value)
	operator_set = ops
	var list = ops.get("list", [])
	for i in list.size():
		var items = {}
		items["text"] = list[i]
		items["id"] = i
		option_list.append(items)
	label("Operator")


func build() -> MonologueField:
	super.build()
	set_items(option_list)
	return self


## Disable operators which are not applicable to the variable dropdown.
func check_value() -> bool:
	var is_valid = true
	
	if super.check_value() and variable:
		var var_index = variable.option_button.selected
		var var_type = variable.option_button.get_item_metadata(var_index)
		
		var is_integer = var_type == MonologueValue.INTEGER
		var block_list = operator_set.get("blocked", [])
		for i in block_list:
			option_button.set_item_disabled(i, !is_integer)
			if !is_integer and value == i:
				value = option_button.get_item_text(0)
				is_valid = false
	
	return is_valid


func vary(dropdown: MonologueOptionButton) -> MonologueField:
	variable = dropdown
	return self
