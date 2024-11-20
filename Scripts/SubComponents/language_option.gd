extends Button


@onready var line_edit: LineEdit = $MarginContainer/HBoxContainer/LineEdit
@onready var line_edit_focus_stylebox: StyleBoxFlat = preload("res://Assets/line_edit_focus.tres")
var line_edit_unfocus_stylebox := StyleBoxEmpty.new()


func _ready() -> void:
	line_edit_unfocus_stylebox.set_content_margin_all(line_edit_focus_stylebox.content_margin_top)
	line_edit_unfocus()


func line_edit_unfocus() -> void:
	line_edit.editable = false
	line_edit.selecting_enabled = false
	line_edit.flat = true
	line_edit.mouse_filter = Control.MOUSE_FILTER_PASS
	
	add_theme_stylebox_override("focus", line_edit_unfocus_stylebox)


func _on_btn_edit_pressed() -> void:
	line_edit.editable = true
	line_edit.selecting_enabled = true
	line_edit.flat = false
	line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
	
	add_theme_stylebox_override("focus", line_edit_focus_stylebox)


func _on_btn_delete_pressed() -> void:
	queue_free()


func _on_line_edit_text_changed(new_text: String) -> void:
	pass # Replace with function body.


func _on_line_edit_focus_exited() -> void:
	line_edit_unfocus()
