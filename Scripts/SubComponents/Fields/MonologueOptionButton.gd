extends OptionButton


var items: Array[Dictionary] : get = _get_items


func _ready() -> void:
	item_selected.connect(_on_field_update)


func _on_field_update(index: int) -> void:
	var value: String = get_item_text(index)
	get_parent().field_update.emit(value)


func _get_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for idx in range(item_count):
		result.append({
			"id": get_item_id(idx),
			"text": get_item_text(idx),
			"metadata": get_item_metadata(idx)
		})
	return result


func get_item_idx_from_text(text: String) -> int:
	for item in items:
		if item.text == text:
			return items.find(item)
	return -1


func set_value(value: Variant) -> void:
	var idx = get_item_idx_from_text(value) if value is String else value
	select(idx)
