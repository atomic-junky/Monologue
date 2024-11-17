class_name WelcomeWindow extends Window

## Callback for loading projects after file selection.
var file_callback = func(path): GlobalSignal.emit("load_project", [path])

@onready var close_button: BaseButton = $PanelContainer/CloseButton
@onready var recent_files: RecentFilesContainer = %RecentFilesContainer
@onready var version_label: Label = $PanelContainer/VBoxContainer/VersionLabel


func _ready():
	version_label.text = "v" + ProjectSettings.get("application/config/version")
	get_parent().connect("resized", _on_resized)
	
	update_size.call_deferred()
	GlobalSignal.add_listener("load_project", _on_load_project)
	GlobalSignal.add_listener("show_welcome", _on_show_welcome)


## Add a file path to the recent files contianer.
func add_recent_file(path: String):
	recent_files.add(path)


func _on_load_project(path: String) -> void:
	add_recent_file(path)
	hide()


func _on_show_welcome(_x) -> void:
	show()


## This is to fix a minor bug where if the user clicks on NoInteractions, the
## WelcomeWindow loses focus, so the cursor will not change to pointing hand
## when hovering over buttons.
func refocus_welcome(event: InputEvent):
	if event is InputEventMouseButton and visible:
		grab_focus()
	
	update_size()


func update_size() -> void:
	move_to_center()
	reset_size()
	size.x = 450


func _on_resized():
	update_size()


func _on_new_file_btn_pressed() -> void:
	GlobalSignal.emit("save_file_request", [load_callback, ["*.json"]])


func _on_open_file_btn_pressed() -> void:
	GlobalSignal.emit("open_file_request", [load_callback, ["*.json"]])


func load_callback(path: String) -> void:
	GlobalSignal.emit("load_project", [path])
