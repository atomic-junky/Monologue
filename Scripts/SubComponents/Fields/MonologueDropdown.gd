class_name MonologueDropdown extends MonologueField


@export var store_index: bool

@onready var label = $Label
@onready var option_button = $OptionButton


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


func propagate(value: Variant) -> void:
	var index = get_item_idx_from_text(value) if value is String else value
	if index >= option_button.item_count:  # avoid falsy check
		option_button.selected = 0
	else:
		option_button.selected = index


func set_items(data: Array, key_text: String = "text", key_id: String = "id",
			key_meta: String = "metadata") -> void:
	option_button.clear()
	for idx in range(data.size()):
		var item_id = data[idx].get(key_id, -1)
		option_button.add_item(data[idx].get(key_text, "undefined"), item_id)
		option_button.set_item_metadata(idx, data[idx].get(key_meta, ""))


func set_label_text(text: String) -> void:
	label.text = text


func _on_item_selected(index: int) -> void:
	var value = index if store_index else option_button.get_item_text(index)
	field_updated.emit(value)
