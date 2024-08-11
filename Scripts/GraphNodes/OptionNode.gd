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


func _on_delete_pressed():
	# create a new option before deleting the last one to prevent zero options
	if panel_node.options_container.get_child_count() == 1:
		panel_node.new_option()
	queue_free()
	panel_node.save_options()


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
		panel_node.save_options()
	
	release_focus()


## Tracks changes to option data to be added to undo/redo history.
func _on_option_data_control_change():
	# optimal to check value changes here before save_options()
	if sentence != sentence_node.text or \
			enable != enable_node.button_pressed or \
			one_shot != one_shot_node.button_pressed:
		
		sentence = sentence_node.text
		enable = enable_node.button_pressed
		one_shot = one_shot_node.button_pressed
		panel_node.save_options()


func _on_sentence_text_changed():
	var option_reference = graph_node.get_option_reference(id)
	if option_reference:
		option_reference.sentence_preview.text = sentence_node.text
