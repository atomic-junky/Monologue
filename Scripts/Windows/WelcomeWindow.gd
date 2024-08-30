class_name WelcomeWindow extends Window


func _ready() -> void:
	var version = ProjectSettings.get("application/config/version")
	$PanelContainer/VersionLabel.text = "v" + version
	get_parent().connect("resized", _on_resized)
	move_to_center()


## This is to fix a minor bug where if the user clicks on NoInteractions, the
## WelcomeWindow loses focus, so the cursor will not change to pointing hand
## when hovering over buttons.
func refocus_welcome(event: InputEvent):
	if event is InputEventMouseButton and visible:
		grab_focus()
	move_to_center()


## Allow the user to close the welcome window by showing the window with
## its close button if the given tab_count is greater than 1.
func show_with_close(tab_count: int = 2) -> void:
	if tab_count > 1:
		$PanelContainer/CloseButton.show()
	else:
		$PanelContainer/CloseButton.hide()
	show() 


func _on_resized():
	move_to_center()
