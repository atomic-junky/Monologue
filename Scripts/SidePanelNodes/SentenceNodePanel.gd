@icon("res://Assets/Icons/NodesIcons/Sentence.svg")

class_name SentenceNodePanel
extends MonologueNodePanel


@onready var character_drop_node: OptionButton = $SpeakerContainer/SubContainer/CharacterDrop
@onready var display_speaker_name_node: LineEdit = $SpeakerContainer/DisplayNameContainer/SubContainer/LineEdit
@onready var display_variant_node: LineEdit = $SpeakerContainer/DisplayVariantContainer/SubContainer/LineEdit
@onready var sentence_edit_node: TextEdit = $SentenceContainer/TextEdit
@onready var voiceline_line_edit: FilePickerLineEdit = $SubContainer/VoicelineContainer/VoiclineLineEdit

var sentence = ""
var speaker_id = 0
var display_speaker_name = ""
var display_variant = ""
var voiceline_path = ""


func _ready():
	for speaker in graph_node.get_parent().speakers:
		character_drop_node.add_item(speaker.get("Reference"), speaker.get("ID"))
	
	voiceline_line_edit.base_file_path = graph_node.get_parent().file_path


func _from_dict(dict):
	id = dict.get("ID")
	sentence = dict.get("Sentence")
	speaker_id = dict.get("SpeakerID")
	display_speaker_name = dict.get("DisplaySpeakerName")
	display_variant = dict.get("DisplayVariant")
	voiceline_path = dict.get("VoicelinePath", "")
	
	if speaker_id >= character_drop_node.item_count:  # avoid falsy check
		graph_node.speaker_id = 0
	else:
		character_drop_node.selected = speaker_id
	display_speaker_name_node.text = display_speaker_name
	sentence_edit_node.text = sentence
	display_variant_node.text = display_variant
	voiceline_line_edit.text = voiceline_path


func _on_character_drop_item_selected(index):
	_on_node_property_change(["speaker_id"], [index])


func _on_line_edit_text_changed(new_text):
	display_variant = new_text
	graph_node.display_variant = new_text
	
	change.emit(self)


func _on_file_picker_line_edit_new_file_path(file_path: String, is_valid: bool) -> void:
	print(file_path)
	voiceline_path = file_path
	graph_node.voiceline_path = file_path
	
	change.emit(self)


func _on_display_name_focus_exited():
	_on_display_name_text_submitted(display_speaker_name_node.text)


func _on_display_name_text_submitted(new_text):
	_on_node_property_change(["display_speaker_name"], [new_text])


func _on_display_variant_focus_exited():
	_on_display_variant_text_submitted(display_variant_node.text)


func _on_display_variant_text_submitted(new_text):
	_on_node_property_change(["display_variant"], [new_text])


func _on_sentence_focus_exited():
	var new_text = sentence_edit_node.text
	_on_node_property_change(["sentence"], [new_text])


func _on_sentence_text_edit_changed():
	graph_node.text_label.text = sentence_edit_node.text
