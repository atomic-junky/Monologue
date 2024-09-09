## A list field that represents a [MonologueGraphEdit] data item.
class_name MonologueList extends MonologueField


enum { SPEAKER, VARIABLE, OPTION }

var add_callback: Callable = GlobalVariables.empty_callback
var delete_scene = preload("res://Objects/SubComponents/DeleteButton.tscn")
var list: Dictionary = {}
var stylebox = preload("res://Assets/ListItem.stylebox")
var type = OPTION

@onready var add_button = $AddButton
@onready var list_label = $ListLabel
@onready var vbox = $VBox


## Add a new option node into the list and show its fields in the vbox.
func append_node_item(id: String) -> void:
	var node = list.get(id)
	var panel = create_item_container()
	var fieldbox = create_item_vbox(panel)
	vbox.add_child(panel)
	for property_name in node.get_property_names():
		var field = node.get(property_name).show(fieldbox)
		field.set_label_text(property_name.capitalize())
	create_delete_button(fieldbox, id)


func clear():
	for child in vbox.get_children():
		child.queue_free()


func create_item_container() -> PanelContainer:
	var item_container = PanelContainer.new()
	item_container.add_theme_stylebox_override("panel", stylebox)
	return item_container


func create_item_vbox(panel: PanelContainer) -> VBoxContainer:
	var item_vbox = VBoxContainer.new()
	panel.add_child(item_vbox)
	return item_vbox


func create_delete_button(fieldbox: VBoxContainer, id: Variant) -> void:
	var delete_container = MarginContainer.new()
	delete_container.add_theme_constant_override("margin_top", 5)
	var delete_button = delete_scene.instantiate()
	delete_button.connect("pressed", _on_delete_button_pressed.bind(id))
	delete_container.add_child(delete_button)
	
	var first_hbox = _find_first_hbox(fieldbox)
	if first_hbox:
		first_hbox.add_child(delete_container)
	else:
		delete_container.queue_free()


func set_label_text(text: String) -> void:
	list_label.text = text


func set_label_visible(can_see: bool) -> void:
	list_label.visible = can_see


func propagate(id_list: Variant) -> void:
	clear()
	for id in id_list:
		match type:
			OPTION: append_node_item(id)
			SPEAKER:  # list of character IDs
				pass
			VARIABLE:  # list of variable names
				pass


func _find_first_hbox(control: Control) -> HBoxContainer:
	for child in control.get_children():
		if child is HBoxContainer:
			return child
	return null


func _on_add_button_pressed() -> void:
	# the add_callback creates the actual instance in its source node, which
	# should call this property's propagate() method to update the list
	add_callback.call()


func _on_delete_button_pressed(id: Variant) -> void:
	list.erase(id)
	field_updated.emit(list.keys())
