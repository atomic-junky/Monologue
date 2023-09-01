extends VBoxContainer


@onready var character_drop_node: OptionButton = $SpeakerContainer/SubContainer/CharacterDrop
@onready var display_speaker_name_node: LineEdit = $SpeakerContainer/DisplayNameContainer/SubContainer/LineEdit
@onready var display_variant_node: LineEdit = $SpeakerContainer/DisplayVariantContainer/SubContainer/LineEdit
@onready var sentence_edit_node: TextEdit = $SentenceContainer/TextEdit

var graph_node

var id = ""
var sentence = ""
var speaker_id = 0
var display_speaker_name = ""
var display_variant = ""


func _ready():
	for speaker in graph_node.get_parent().speakers:
		character_drop_node.add_item(speaker.get("Reference"), speaker.get("ID"))


func _from_dict(dict):
	id = dict.get("ID")
	sentence = dict.get("Sentence")
	speaker_id = dict.get("SpeakerID")
	display_speaker_name = dict.get("DisplaySpeakerName")
	display_variant = dict.get("DisplayVariant")
	
	if speaker_id:
		character_drop_node.select(speaker_id)
	display_speaker_name_node.text = display_speaker_name
	sentence_edit_node.text = sentence
	display_variant_node.text = display_variant


func _on_sentence_text_edit_changed():
	assert(graph_node)
	sentence = sentence_edit_node.text
	graph_node.sentence = sentence
	
	graph_node.update_preview()


func _on_display_name_line_edit_text_changed(new_text):
	assert(graph_node)
	display_speaker_name = new_text
	graph_node.display_speaker_name = display_speaker_name
	
	graph_node.update_preview()


func _on_character_drop_item_selected(index):
	graph_node.speaker_id = index


func _on_line_edit_text_changed(new_text):
	display_variant = new_text
	graph_node.display_variant = new_text
