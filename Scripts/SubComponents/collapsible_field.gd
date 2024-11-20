class_name CollapsibleField extends VBoxContainer


signal add_pressed

@export var show_add_button: bool = false
@export var separate_items: bool = false
@export var allow_reorder: bool = false

@onready var button := $Button
@onready var collapsible_container := $CollapsibleContainer
@onready var vbox := %FieldContainer
@onready var r_vbox := %ReorderableFieldContainer
@onready var add_button := %AddButton

@onready var list_item_container := preload("res://Objects/SubComponents/list_item_container.tscn")
@onready var icon_close := preload("res://Assets/Icons/arrow_right.svg")
@onready var icon_open := preload("res://Assets/Icons/arrow_down.svg")


func _ready() -> void:
	button.icon = icon_close
	add_button.visible = show_add_button
	close()


func add_item(item: Control, force_readable_name: bool = false) -> void:
	grab_focus()
	if allow_reorder:
		var item_container: ListItemContainer = list_item_container.instantiate()
		r_vbox.add_child(item_container, force_readable_name)
		item_container.set_item(item)
		return
	
	vbox.add_child(item, force_readable_name)


func set_title(text: String) -> void:
	button.text = text


func get_items() -> Array[Node]:
	if allow_reorder:
		var items: Array = []
		for item in vbox.get_children():
			items.append(item.get_item())
		return items
	
	return vbox.get_children().filter(func(c): return c is not HSeparator)


func clear() -> void:
	grab_focus()
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	
	for child in r_vbox.get_children():
		r_vbox.remove_child(child)
		child.queue_free()


func _on_button_pressed() -> void:
	if collapsible_container.visible:
		close()
	else:
		open()


func open() -> void:
	button.icon = icon_open
	collapsible_container.show()


func close() -> void:
	button.icon = icon_close
	collapsible_container.hide()


func _on_add_button_pressed() -> void:
	add_pressed.emit()
