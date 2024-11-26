extends PanelContainer


@onready var line_edit: LineEdit = $MarginContainer/HBoxContainer/LineEdit


func focus() -> void:
	line_edit.grab_focus()
	line_edit.select_all()
