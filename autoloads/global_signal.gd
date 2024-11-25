extends Node

# Keeps track of what listeners have been registered.
var _listeners = {}

# Adds a new global listener that is a method linked to signal_name.
func add_listener(signal_name: String, method: Callable) -> void:
	if not _listeners.has(signal_name):
		_listeners[signal_name] = []
		
	_listeners[signal_name].append(method)


# Remove registered method linked to a signal_name.
func remove_listener(signal_name: String, method: Callable) -> void:
	if not _listeners.has(signal_name): return
	if not _listeners[signal_name].has(method): return

	_listeners[signal_name].erase(method)

# Call all the methods linked with a signal_name.
func emit(signal_name: String, args: Array = []):
	if not _listeners.has(signal_name):
		return
	
	for method in _listeners[signal_name]:
		if not method.is_valid():
			_listeners[signal_name].erase(method)
			continue
		method.callv(args)
