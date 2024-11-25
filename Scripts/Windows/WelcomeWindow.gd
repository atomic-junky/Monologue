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
	GlobalSignal.add_listener("show_welcome", show)
	GlobalSignal.add_listener("hide_welcome", hide)


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
