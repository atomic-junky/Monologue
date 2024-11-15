class_name RecentFilesContainer extends VBoxContainer


@export var button_container: Control
@export var save_path: String = "user://history.save"

@onready var button_scene: PackedScene = preload("res://scenes/prefabs/windows/welcome_window/recent_file_button.tscn")

var recent_filepaths: Array = []


func _ready() -> void:
	create_file()
	load_file()
	show_or_hide()


## Adds a new filepath as recent file and save it to the history file.
func add(filepath: String) -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		recent_filepaths.erase(filepath)
		recent_filepaths.push_front(filepath)
		file.store_string(JSON.stringify(recent_filepaths.slice(0, 10)))


## Create the recent file history save in user directory if it doesn't exist.
func create_file() -> void:
	if not FileAccess.file_exists(save_path):
		FileAccess.open(save_path, FileAccess.WRITE)


## Load the recent file history save and create buttons for it.
func load_file() -> void:
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var data = parse_history(file.get_as_text())
		file.close()
		
		for path in data.slice(0, 3):
			recent_filepaths.append(path)
			var btn = button_scene.instantiate()
			var btn_text = path.replace("\\", "/")
			btn_text = btn_text.replace("//", "/")
			btn_text = btn_text.split("/")
			if btn_text.size() >= 2:
				btn_text = btn_text.slice(-2, btn_text.size())
				btn_text = btn_text[0].path_join(btn_text[1])
			else:
				btn_text = btn_text.back()
			
			btn.text = Util.truncate_filename(btn_text)
			btn.pressed.connect(GlobalSignal.emit.bind("load_project", [path]))
			button_container.add_child(btn)


## Return only the recent files that still exist as a JSON array.
func parse_history(text: String) -> Array:
	var data = JSON.parse_string(text)
	if data is Array:
		return data.filter(func(p): return FileAccess.file_exists(p))
	return []


## Show container if recent file buttons are present, otherwise hide it.
func show_or_hide() -> void:
	if button_container.get_child_count() > 0:
		show()
	else:
		hide()
