extends Window


func _ready():
	$PanelContainer/VersionLabel.text = "v" + ProjectSettings.get("application/config/version")

## This is to fix a minor bug where if the user clicks on NoInteractions, the
## WelcomeWindow loses focus, so the cursor will not change to pointing hand
## when hovering over buttons. Small but noticeable pet peeve.
func refocus_welcome(event: InputEvent):
	if event is InputEventMouseButton and visible:
		grab_focus()

func _on_control_resized():
	var new_pos: Vector2 = get_parent().get_window().get_size_with_decorations() / 2 - size / 2
	position = new_pos
