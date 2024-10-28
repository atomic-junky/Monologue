extends Window


func _ready():
	$PanelContainer/VBoxContainer/VersionLabel.text = "v" + ProjectSettings.get("application/config/version")
	get_parent().connect("resized", _on_resized)
	
	move_to_center.call_deferred()
	GlobalSignal.add_listener("load_project", _on_load_project)
	GlobalSignal.add_listener("show_welcome", _on_show_welcome)


func _on_load_project(_path, _new_graph) -> void:
	hide()


func _on_show_welcome(_x) -> void:
	show()


## This is to fix a minor bug where if the user clicks on NoInteractions, the
## WelcomeWindow loses focus, so the cursor will not change to pointing hand
## when hovering over buttons.
func refocus_welcome(event: InputEvent):
	if event is InputEventMouseButton and visible:
		grab_focus()
	
	move_to_center()


func _on_resized():
	move_to_center()
