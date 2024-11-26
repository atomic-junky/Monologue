extends Window


func _ready() -> void:
	var version = ProjectSettings.get("application/config/version")
	var is_pre_release = version.split("-").size() > 1
	
	visible = is_pre_release
	grab_focus()

func _on_button_pressed() -> void:
	hide()
