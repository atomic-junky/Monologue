extends VBoxContainer


signal add_pressed

@export var show_add_button: bool = false

@onready var button := $Button
@onready var collapsible_container: CollapsibleContainer = $CollapsibleContainer
@onready var vbox := %FieldContainer
@onready var add_button := %AddButton

@onready var icon_close := preload("res://Assets/Icons/arrow_right.svg")
@onready var icon_open := preload("res://Assets/Icons/arrow_down.svg")


func _ready() -> void:
	button.icon = icon_close
	collapsible_container.close.call_deferred()
	add_button.visible = show_add_button


func add_item(item: Control, force_readable_name: bool = false) -> void:
	var is_open: bool = collapsible_container.is_opened()
	collapsible_container.close()
	
	vbox.add_child(item, force_readable_name)
	
	if is_open:
		button.icon = icon_open
		# TODO: Fix collapsible container to avoid using this temporary fix.
		await get_tree().process_frame
		await get_tree().process_frame
		collapsible_container.open.call_deferred()


func set_title(text: String) -> void:
	button.text = text


func get_items() -> Array[Node]:
	return vbox.get_children()


func _on_button_pressed() -> void:
	if collapsible_container.is_opened():
		button.icon = icon_close
		collapsible_container.close()
	else:
		button.icon = icon_open
		collapsible_container.open()


func _on_add_button_pressed() -> void:
	add_pressed.emit()
