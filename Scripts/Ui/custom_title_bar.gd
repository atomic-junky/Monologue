extends Control

var drag_point = null

func _on_gui_input(ev: InputEvent) -> void:
	if ProjectSettings.get_setting("display/window/size/borderless") == false:
		return
	
	if ev is InputEventMouseButton:
		if ev.double_click:
			_on_tb_size_button_pressed()
		elif ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				# Grab it.
				drag_point = get_global_mouse_position()
			else:
				# Release it.
				drag_point = null
	
	if ev is InputEventMouseMotion and drag_point != null:
		var mouse_screen_position = get_window().position as Vector2 + get_global_mouse_position()
		get_window().position = mouse_screen_position - drag_point


func _on_tb_close_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_tb_size_button_pressed() -> void:
	var win_mode = DisplayServer.window_get_mode()
	
	match win_mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_tb_reduce_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
