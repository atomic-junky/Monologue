class_name WelcomeWindow extends Window


@export var tab_bar: TabBar

## Callback for loading projects after file selection.
var file_callback = func(path): GlobalSignal.emit("load_project", [path])

@onready var close_button: BaseButton = $PanelContainer/CloseButton
@onready var version_label: Label = $PanelContainer/VersionLabel
@onready var recent_files: RecentFilesContainer = %RecentFilesContainer


func _ready() -> void:
	var version = ProjectSettings.get("application/config/version")
	version_label.text = "v" + version
	get_parent().connect("resized", _on_resized)
	move_to_center()


## Add a file path to the recent files contianer.
func add_recent_file(path: String):
	recent_files.add(path)


## Callback for closing the welcome window.
func close() -> void:
	GlobalSignal.emit("hide_dimmer")
	hide()


## This is to fix a minor bug where if the user clicks on NoInteractions, the
## WelcomeWindow loses focus, so the cursor will not change to pointing hand
## when hovering over buttons.
func refocus_welcome(event: InputEvent):
	if event is InputEventMouseButton and visible:
		grab_focus()
	move_to_center()


## Show the window with close button if the given tab_count is greater than 1.
func open(show_close_button: bool = false) -> void:
	if show_close_button:
		close_button.show()
	else:
		close_button.hide()
	GlobalSignal.emit("show_dimmer")
	show()


func _on_close_btn_pressed():
	GlobalSignal.emit("previous_tab")


func _on_new_file_btn_pressed():
	GlobalSignal.emit("save_file_request", [file_callback, ["*.json"]])


func _on_open_file_btn_pressed():
	GlobalSignal.emit("open_file_request", [file_callback, ["*.json"]])


func _on_resized():
	move_to_center()
