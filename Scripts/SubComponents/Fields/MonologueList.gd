## A list field that represents a [MonologueGraphEdit] data item.
class_name MonologueList extends MonologueField


enum { CHARACTER, VARIABLE, OPTION }

## Secretly a dictionary for optimized performance.
var list: Dictionary = {}  # key = item id, value = [array]
var stylebox = preload("res://Assets/ListItem.stylebox")
var scene: PackedScene
var type = OPTION

var graph: MonologueGraphEdit

@onready var vbox = $VBox
@onready var add_button = $AddButton
@onready var list_label = $ListLabel


## Add an option node into the list and show its fields in the vbox.
func append_option(node_id: String) -> bool:
	var is_successful = false
	var node = graph.get_node_by_id(node_id)
	if node:
		var panel = create_container()
		for property_name in node.get_property_names():
			# OptionNode contains hidden NextID, do not show it
			if property_name != "next_id":
				var field = node.get(property_name).show(panel)
				field.set_label_text(property_name.capitalize())
		vbox.add_child(panel)
		list[node.id] = node
		is_successful = true
	return is_successful


func clear():
	for child in vbox.get_children():
		child.queue_free()
	list = {}


func create_container():
	var container = PanelContainer.new()
	container.add_theme_stylebox_override("panel", stylebox)
	return container


func set_label_text(text: String) -> void:
	list_label.text = text


func propagate(iterable: Variant) -> void:
	clear()
	for element in iterable:
		match type:
			OPTION:
				append_option(element)
			CHARACTER:  # list of character IDs
				pass
			VARIABLE:  # list of variable names
				pass

func _on_add_button_pressed() -> void:
	field_updated.emit()
