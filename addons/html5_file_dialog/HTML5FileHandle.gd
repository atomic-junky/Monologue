extends RefCounted
class_name HTML5FileHandle
## File handle for files uploaded through the HTML5FileDialog node [br]
## Used for reading the contents of files

## The text file contents are done loading. [br]
## Triggers sometime after `as_text()` [br]
## Alternatively, you can use `await object.as_text()`
signal text_loaded(text:String)
## The binary file contents are done reading [br]
## Triggers sometime after `as_buffer()` [br]
## Alternatively, you can use `await object.as_buffer()`
signal buffer_loaded(buffer:PackedByteArray)

## Filepath
@export var path:String
## Filename
@export var name:String
## Unix epoch
@export var last_modified:float

## Wether or not to cache the contents when as_text() or as_bufffer() was called, for use in subsequent calls.
@export var cache_contents:bool = true

var js_file:JavaScriptObject

var _js_text_callback:JavaScriptObject
var _js_buffer_callback:JavaScriptObject

var _contents_text:String
var _contents_buffer:PackedByteArray

func _init(JSFile:JavaScriptObject):
	assert(OS.get_name() == 'Web', "HTML5FileHandles can only be used in a web export, and should only be created by a HTML5FileDialog node.")
	js_file = JSFile
	
	name = js_file.name
	last_modified = js_file.lastModified
	path = js_file.webkitRelativePath

## Returns the file's contents as a utf8 string [br]
## Async function! Await this, or connect to the `text_loaded` signal.
func as_text()->String:
	if cache_contents and _contents_text != '':
		return _contents_text
	if _js_text_callback == null:
		_js_text_callback = JavaScriptBridge.create_callback(_text_callback)
	js_file.text().then(_js_text_callback)
	
	return await text_loaded

## Returns the file's contents as a PackedByteArray [br]
## Async function! Await this, or connect to the `buffer_loaded` signal.
func as_buffer()->PackedByteArray:
	if not _contents_buffer.is_empty():
		return _contents_buffer
	if _js_buffer_callback == null:
		_js_buffer_callback = JavaScriptBridge.create_callback(_buffer_callback)
	js_file.arrayBuffer().then(_js_buffer_callback)
	return await buffer_loaded

func _text_callback(args):
	if cache_contents:
		_contents_text = args[0]
	text_loaded.emit(args[0])

func _buffer_callback(args):
	# NOTE: EVIL WORKAROUND
	# for the life of me i cannot find any information on converting a JavaScriptObject (ArrayBuffer)
	# into its godot counterpart (PackedByteArray)
	#
	# So instead we write the buffer to a temporary variable on JS' `window`
	# And then read it back through eval() immediately, which for some reason does perform the conversion
	# (and then remove the variable again)
	var out:PackedByteArray
	var janky_varname = "HTML5FileHandle_"+str(get_instance_id()).replace('-','_')+'_buffer'
	
	var window = JavaScriptBridge.get_interface("window")
	window[janky_varname] = args[0]
	out = JavaScriptBridge.eval("window."+janky_varname)
	window[janky_varname] = null
	
	if cache_contents:
		_contents_buffer = out
	
	buffer_loaded.emit(out)
