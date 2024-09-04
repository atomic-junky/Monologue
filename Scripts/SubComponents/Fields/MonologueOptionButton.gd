class_name MonologueOptionButton extends MonologueField


## Set this to true if value is stored as index instead of text.
var is_store_index: bool
var option_button: OptionButton


func build() -> MonologueField:
	option_button = OptionButton.new()
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_button.connect("item_selected", update_value)
	hbox.add_child(option_button, true)
	return self


## Checks if value is within the option button range. Resets to 0 if invalid.
## Returns true if value is valid, false otherwise.
func check_value() -> bool:
	var is_str = value is String
	var index = get_item_idx_from_text(value) if is_str else value
	
	if index >= option_button.item_count:  # avoid falsy check
		if is_str:
			value = option_button.get_item_text(0)
		else:
			value = 0
		panel.graph_node.set(property, value)
		return false
	else:
		value = value  # reassign to trigger set_value()
		return true


func get_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for idx in range(option_button.item_count):
		result.append({
			"id": option_button.get_item_id(idx),
			"text": option_button.get_item_text(idx),
			"metadata": option_button.get_item_metadata(idx)
		})
	return result


func get_item_idx_from_text(text: String) -> int:
	var items = get_items()
	for item in items:
		if item.text == text:
			return items.find(item)
	return -1


func set_items(data: Array, key_t: String = "text",
		key_i: String = "id", key_m: String = "metadata") -> MonologueField:
	option_button.clear()
	for idx in range(data.size()):
		var item_id = data[idx].get(key_i, -1)
		option_button.add_item(data[idx].get(key_t, "undefined"), item_id)
		option_button.set_item_metadata(idx, data[idx].get(key_m, ""))
	check_value()
	return self


func set_value(new_value: Variant) -> void:
	super.set_value(new_value)
	if option_button:
		var is_str = new_value is String
		var index = get_item_idx_from_text(new_value) if is_str else new_value
		option_button.selected = index


func update_value(new_value: Variant) -> bool:
	if is_store_index and new_value is String:
		new_value = get_item_idx_from_text(new_value)
	
	elif not is_store_index and new_value is int:
		new_value = option_button.get_item_text(new_value)
	
	return super.update_value(new_value)
