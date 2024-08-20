class_name MonologueOptionButton extends OptionButton


var items: Array[Dictionary] : get = _get_items


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


func get_item_id_from_text(text: String) -> int:
	for item in items:
		if item.text == text:
			return item.id
	return -1
