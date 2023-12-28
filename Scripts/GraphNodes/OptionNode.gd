class_name OptionNode

extends PanelContainer

@onready var sentence_node = $MarginContainer/MainContainer/SentenceContainer/TextEdit
@onready var enable_node: CheckBox = $MarginContainer/MainContainer/EnableBtn
@onready var one_shot_node: CheckBox = $MarginContainer/MainContainer/OneShotBtn
@onready var id_label: Label = $MarginContainer/MainContainer/IDLabel

var panel_node
var graph_node

var id = UUID.v4()
var node_type = "NodeOption"
var sentence = ""
var enable = true
var one_shot = false


func _to_dict():
	return {
		"$type": node_type,
		"ID": id,
		"Sentence": sentence,
		"Enable": enable,
		"OneShot": one_shot
	}


func _from_dict(dict):
	if dict != null:
		id = dict.get("ID")
		sentence = dict.get("Sentence")
		enable = dict.get("Enable")
		one_shot = dict.get("OneShot")
	
	sentence_node.text = sentence
	enable_node.button_pressed = enable
	one_shot_node.button_pressed = one_shot
	
	id_label.text = id + " (click to copy)"


func _on_delete_pressed():
	queue_free()
	update_ref()


func _on_id_label_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		DisplayServer.clipboard_set(id)


func update_ref():
	id_label.text = id + " (click to copy)"
	
	sentence = sentence_node.text
	enable = enable_node.button_pressed
	one_shot = one_shot_node.button_pressed
	
	panel_node.change.emit(panel_node)
