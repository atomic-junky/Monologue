class_name DeleteOptionHistory
extends AddOptionHistory


func _init(choice_node: ChoiceNode, option_node: OptionNode):
	super(choice_node, option_node)
	
	var swap_callback = _undo_callback
	_undo_callback = _redo_callback
	_redo_callback = swap_callback
