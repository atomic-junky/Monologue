## Swaps the undo/redo callback of [AddOptionHistory].
class_name DeleteOptionHistory
extends AddOptionHistory


## When the last option is deleted, a new option is created in its place
## with a renewed ID. Track this so that we can re-delete this.
var renewed_id: String


func _init(choice_node: ChoiceNode, option_node: OptionNode):
	super(choice_node, option_node)
	renewed_id = ""
	
	var swap_callback = _undo_callback
	_undo_callback = _redo_callback
	_redo_callback = swap_callback


func delete_option():
	var renewed_option = super.delete_option()
	if renewed_option:
		# if there is a renewed option but its ID is not tracked yet, track it
		if renewed_id.is_empty():
			renewed_id = renewed_option.id
		# if there is a renewed option but its ID already tracked, restore it
		else:
			renewed_option.id = renewed_id
			renewed_option.update_ref()


func delete_renewal(panel: ChoiceNodePanel):
	if not renewed_id.is_empty():
		var renewed_option = panel.get_option_node(renewed_id)
		if renewed_option:
			renewed_option.delete()
