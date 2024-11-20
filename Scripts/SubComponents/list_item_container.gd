class_name ListItemContainer extends PanelContainer


@onready var hbox := $VBoxContainer/HBoxContainer


func set_item(item: Control) -> void:
	hbox.add_child(item)


func get_item() -> Control:
	return hbox.get_child(1)
