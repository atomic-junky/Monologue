class_name OptionNode
extends PanelContainer


@onready var ribbon_instance = preload("res://Objects/SubComponents/Ribbon.tscn")
@onready var sentence_node = $MarginContainer/MainContainer/SentenceContainer/TextEdit
@onready var enable_node: CheckBox = $MarginContainer/MainContainer/EnableBtn
@onready var one_shot_node: CheckBox = $MarginContainer/MainContainer/OneShotBtn
@onready var id_line_edit: LineEdit = $MarginContainer/MainContainer/IDContainer/IDLineEdit

var panel_node: ChoiceNodePanel
var graph_node: ChoiceNode

var id = UUID.v4()
var next_id = -1
var node_type = "NodeOption"
var sentence = ""
var enable = true
var one_shot = false


func _to_dict():
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_id,
		"Sentence": sentence,
		"Enable": enable,
		"OneShot": one_shot
	}


func _from_dict(dict):
	if dict != null:
		id = dict.get("ID")
		next_id = dict.get("NextID")
		sentence = dict.get("Sentence")
		enable = dict.get("Enable")
		one_shot = dict.get("OneShot")
	
	sentence_node.text = sentence
	enable_node.button_pressed = enable
	one_shot_node.button_pressed = one_shot
	id_line_edit.text = id


## Deletes the current option. Returns a newly created option node if the
## panel has no more options (the panel requires a minimum of 1 option).
## Therefore, this method returns null on successful delete.
func delete() -> OptionNode:
	var renewed_option = null
	# create a new option before deleting the last one to prevent zero options
	if panel_node.options_container.get_child_count() == 1:
		renewed_option = panel_node.new_option()
	queue_free()
	update_ref()
	return renewed_option


## Update referenced values in side panel.
func update_ref():
	id_line_edit.text = id
	sentence = sentence_node.text
	enable = enable_node.button_pressed
	one_shot = one_shot_node.button_pressed
	
	panel_node.change.emit(panel_node)


func _on_delete_pressed():
	var message = "Delete option (id: %s)"
	var undo_redo = graph_node.get_parent().undo_redo
	var delete_history = DeleteOptionHistory.new(graph_node, self)
	undo_redo.create_action(message % [id])
	undo_redo.add_prepared_history(delete_history)
	undo_redo.commit_action()


func _on_id_copy_pressed():
	DisplayServer.clipboard_set(id)
	var ribbon = ribbon_instance.instantiate()
	ribbon.position = get_viewport().get_mouse_position()
	panel_node.side_panel.control_node.add_child(ribbon)


func _on_id_focus_exited():
	_on_id_text_submitted(id_line_edit.text)


func _on_id_text_submitted(new_id):
	if new_id != id:
		var graph: MonologueGraphEdit = graph_node.get_parent()
		# if the new_id exists in any node or option, revert to previous id
		if graph.is_option_id_exists(new_id) or graph.get_node_by_id(new_id):
			id_line_edit.text = id
			return
		
		id = new_id
		panel_node.change.emit(panel_node)
	
	release_focus()
