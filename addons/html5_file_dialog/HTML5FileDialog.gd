@tool
@icon("icon.svg")
extends Node
class_name HTML5FileDialog
## File dialog for web exports [br]
## Works on (multiple) files and directories [br]
## Works on all major browsers [br]
## returns HTML5FileHandle files, which are used to read the contents of uploaded files [br]

## Emitted after calling `show()`. May incorrectly emit if there has not been sufficient browser interaction from the user when `show` is called.
signal shown()

## One file selected. Only triggers with the "Open File" file mode
signal file_selected(file:HTML5FileHandle)
## One or more files selected. Only triggers with the "Open File" file mode
signal files_selected(files:Array[HTML5FileHandle])
## One directory selected. Only triggers with the "Open Directory" file mode [br]
## Returns all the files inside the directory, including those in sub-directories.
signal dir_selected(files:Array[HTML5FileHandle])
## One or more directories selected. Only triggers with the "Open Directories" file mode [br]
## Returns all the files inside the directories, including those in sub-directories.
signal dirs_selected(files:Array[HTML5FileHandle])

## Triggers no matter what the file mode is set to, as long as the user selected something.
signal anything_selected(files:Array[HTML5FileDialog])

enum FileMode {
	OPEN_FILE,			## Open a single file
	OPEN_FILES,			## Open multiple files
	OPEN_DIRECTORY,		## Open a single directory
	OPEN_DIRECTORIES,	## Open multiple directories
}
## Type of dialog that appears when you call [method show]
@export var file_mode:FileMode = FileMode.OPEN_FILE
## Specify what kind of files may be selected. [br]
## Leave empty for anything. [br]
## Read the MDN page for more information: [br][url]https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/file#unique_file_type_specifiers[/url]
@export var filters:PackedStringArray = []

# interface is the resulting object of the js_snippet
var interface:JavaScriptObject
# is_web is a shortcut boolean for checking if the current build is running in browser
var is_web:bool = OS.get_name() == 'Web'
# JS version of the _on_js_callback function
var _callback:JavaScriptObject

# snippet of code that handles stuff on the javascript side of things
const js_snippet := """
if (window.html5filedialoginterface == null) {
	window.html5filedialoginterface = {
		callbacks: {},
		buffers: {},

		register_dialog: function(id, FileMode, filter, callback) {
			let root = document.getElementsByTagName('body')[0];
			let input = document.createElement("input");

			input.setAttribute('id','html5filedialog-'+id);
			input.setAttribute('type','file');
			input.setAttribute('style','display: none;');
			input.setAttribute('data-id', ''+id);

			if (FileMode == "OPEN_DIRECTORY" || FileMode == "OPEN_DIRECTORIES") {
				input.setAttribute("directory", 'true');
				input.setAttribute('webkitdirectory','true');
			}

			if (FileMode == "OPEN_DIRECTORIES" || FileMode == "OPEN_FILES") {
				input.setAttribute('multiple','true');
			}
			
			if (filter != "") {
				input.setAttribute('accept',filter)
			}
		
			input.addEventListener('change', window.html5filedialoginterface.onchanged)
			window.html5filedialoginterface.callbacks[''+id] = callback;
			root.appendChild(input);
			
			console.log("HTML5FileDialog: registered dialog "+id);
			
			return id;
		},

		deregister_dialog: function(id) {
			let input = document.getElementById('html5filedialog-'+id);
			if (input != null) {
				console.log("HTML5FileDialog: deregistering "+id);
				input.remove();
			} else {
				console.log("HTML5FileDialog: ERROR, attempted to deregister non-existing dialog "+id);
			}
		},
 
		prompt_dialog: function(id) {
			console.log("HTML5FileDialog: opening dialog for "+id);
			let input = document.getElementById('html5filedialog-'+id);
			input.click();
		},

		onchanged: function(event) {
			let id = event.target.getAttribute('data-id')+'';
			console.log("HTML5FileDialog: change event for "+id);
			
			let out = [];
			for (const file of event.target.files) {
				out.push(file);
			}
			
			let callback = window.html5filedialoginterface.callbacks[id]
			callback(...out);
		}
	}
}
"""




func _ready():
	if Engine.is_editor_hint():
		update_configuration_warnings()
	
	if is_web:
		JavaScriptBridge.eval(js_snippet)
		interface = JavaScriptBridge.get_interface('html5filedialoginterface')
		
		_callback = JavaScriptBridge.create_callback(_on_js_callback)
		interface.register_dialog(get_instance_id(), FileMode.keys()[file_mode], ','.join(filters), _callback)

## Show the dialog
func show():
	assert(is_web, "HTML5FileDialog node only works in web exports!")
	assert(is_node_ready(), "HTML5FileDialog cannot be shown before its _ready! did you forget to call add_child()?")
	assert(interface != null, "HTML5FileDialog JS interface is null! This is probably a bug, please report it at https://gitlab.com/mocchapi/godot-4-html5-file-dialogs/-/issues")
	interface.prompt_dialog(get_instance_id())
	shown.emit()

# Callback triggered from js when a file is uploaded
func _on_js_callback(files):
	var out:Array[HTML5FileHandle] = []
	for file in files:
		out.append(HTML5FileHandle.new(file))
	
	match file_mode:
		FileMode.OPEN_FILE:
			file_selected.emit(out[0])
		FileMode.OPEN_FILES:
			files_selected.emit(out)
		FileMode.OPEN_DIRECTORY:
			dir_selected.emit(out)
		FileMode.OPEN_DIRECTORIES:
			dirs_selected.emit(out)

	anything_selected.emit(out)

func _get_configuration_warnings()->PackedStringArray:
	var out:Array = []
	if OS.get_name() != 'Web':
		out.append("This node only works on web exports! Calling its functions in a regular build will result in failed assertions")
	out.append("This node's attributes must not be changed after _ready() is called")
	return out

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if interface:
			# Removes the <input> element when this node is freed
			interface.deregister_dialog(get_instance_id())
