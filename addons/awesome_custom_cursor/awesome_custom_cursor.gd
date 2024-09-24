@tool
extends EditorPlugin
const UPDATE_BUTTON_SCENE = preload ("res://addons/awesome_custom_cursor/editor/update_button.tscn")
var update_button

const CURSOR_DATA: Dictionary = {
	"path": "res://addons/awesome_custom_cursor/Autoloads/Cursor.tscn",
	"name": "Cursor"
}

var cursor_scene

func _enter_tree():
	update_button = UPDATE_BUTTON_SCENE.instantiate()
	update_button.editor_plugin = self
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, update_button)

	add_autoload_singleton(CURSOR_DATA.name, CURSOR_DATA.path)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, update_button)
	update_button.queue_free()

	remove_autoload_singleton(CURSOR_DATA.name)
