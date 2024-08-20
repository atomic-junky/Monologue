extends Node


# The DPI of a 23.8 inch display with a 1920x1080 resolution
const BASE_SCALE_DPI = 92.56


func _ready() -> void:
	var screen_dpi = DisplayServer.screen_get_dpi()
	var screen_size = DisplayServer.window_get_size()
	# Guess the screen scale because [DisplayServer.screen_get_scale()] only work on macOS and Linux.
	var guessed_screen_scale: float = min(round(screen_dpi/BASE_SCALE_DPI), 2.0)
	
	DisplayServer.window_set_size(screen_size*guessed_screen_scale)
	ProjectSettings.set_setting("display/window/stretch/scale", guessed_screen_scale)
	ProjectSettings.save_custom("user://override.cfg")
	get_window().move_to_center()
