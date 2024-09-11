## A list field that represents a [MonologueGraphEdit] data item.
class_name MonologueList extends MonologueField


enum { SPEAKER, VARIABLE, OPTION }

var delete_scene = preload("res://Objects/SubComponents/DeleteButton.tscn")
var stylebox = preload("res://Assets/ListItem.stylebox")

var add_callback: Callable = GlobalVariables.empty_callback
var get_callback: Callable = GlobalVariables.empty_callback
var data_list: Array = []
var type = OPTION

@onready var add_button = $AddButton
@onready var list_label = $ListLabel
@onready var vbox = $VBox


## Add a new option node into the list and show its fields in the vbox.
func append_node_item(node: Node) -> void:
	var panel = create_item_container()
	var fieldbox = create_item_vbox(panel)
	vbox.add_child(panel, true)
	for property_name in node.get_property_names():
		var field = node.get(property_name).show(fieldbox)
		field.set_label_text(property_name.capitalize())
	create_delete_button(fieldbox, node.id.value)


func clear_list():
	for child in vbox.get_children():
		child.queue_free()
	data_list = []


func create_item_container() -> PanelContainer:
	var item_container = PanelContainer.new()
	item_container.add_theme_stylebox_override("panel", stylebox)
	return item_container


func create_item_vbox(panel: PanelContainer) -> VBoxContainer:
	var item_vbox = VBoxContainer.new()
	panel.add_child(item_vbox, true)
	return item_vbox


func create_delete_button(fieldbox: VBoxContainer, id: Variant) -> void:
	var delete_container = MarginContainer.new()
	delete_container.add_theme_constant_override("margin_top", 5)
	var delete_button = delete_scene.instantiate()
	delete_button.connect("pressed", _on_delete_button_pressed.bind(id))
	delete_container.add_child(delete_button, true)
	
	var first_hbox = _find_first_hbox(fieldbox)
	if first_hbox:
		first_hbox.add_child(delete_container, true)
	else:
		delete_container.queue_free()


func set_label_text(text: String) -> void:
	list_label.text = text


func set_label_visible(can_see: bool) -> void:
	list_label.visible = can_see


func propagate(_data: Variant) -> void:
	clear_list()
	data_list = get_callback.call()
	for reference in data_list:
		match type:
			OPTION: append_node_item(reference)
	
	# map to to_dict
	if type == OPTION:
		data_list = data_list.map(func(r): return r._to_dict())


func _find_first_hbox(control: Control) -> HBoxContainer:
	for child in control.get_children():
		if child is HBoxContainer:
			return child
	return null


func _on_add_button_pressed() -> void:
	# the add_callback creates the actual instance in its source node
	var new_item = add_callback.call()
	data_list.append(new_item._to_dict())
	match type:
		OPTION: append_node_item(new_item)
	field_updated.emit(data_list)


func _on_delete_button_pressed(id: Variant) -> void:
	for reference in data_list:
		if reference.get("ID") == id:
			data_list.erase(reference)
			break
	field_updated.emit(data_list)
