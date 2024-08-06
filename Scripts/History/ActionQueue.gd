## Acts as a storage queue for replaying ActionHistory.
class_name ActionQueue
extends RefCounted


## Maximum amount of actions that can be stored in queue.
## Good idea to have a limit so array re-indexing is not too slow.
const DEFAULT_LIMIT = 50

## The historical list of actions.
var actions: Array[ActionHistory]
## Current index in the queue. Starts at -1.
var current_index: int

## Keeps track of queue limit. Must be greater than zero.
var _queue_limit: int


## Constructor to initialize queue with optional [param limit].
func _init(limit = DEFAULT_LIMIT):
	_queue_limit = max(1, limit)
	actions = []
	current_index = -1


## Erase actions after the [member current_index], then add the given
## [param history] to the queue. If the queue is full, remove first action.
func add(history: ActionHistory):
	if actions.size() > _queue_limit:
		# if over the queue limit, remove first element from queue
		# index stays the same because an element was removed
		actions.pop_front()
	else:
		# otherwise, index goes up due to new action to be added into queue
		current_index = current_index + 1
	
	# resize to drop all actions after the current_index
	actions.resize(current_index)
	# finally, add the new action to the queue
	actions.append(history)


## Calls the undo function of the current action and move the index backward.
## Returns true if successful, false otherwise.
func previous() -> bool:
	if current_index >= 0:
		actions[current_index].undo()
		# decrement index by 1, cannot go below -1
		# -1 is when there are no more actions to trigger in the queue
		current_index = max(-1, current_index - 1)
		return true
	return false


## Calls the redo function of the current action and move the index forward.
## Returns true if successful, false otherwise.
func next() -> bool:
	# index increment happens first for redo
	var increment = current_index + 1
	if increment < actions.size():
		actions[increment].redo()
		current_index = increment
		return true
	return false
