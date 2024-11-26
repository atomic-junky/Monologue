extends Button


func _on_pressed() -> void:
	GlobalSignal.emit("enable_picker_mode")
