@icon("res://Assets/Icons/NodesIcons/Sentence.svg")

class_name SentenceNodePanel extends MonologueNodePanel


@onready var speaker_field: OptionButton = %Field_Speaker
var speakers = []

func _load():
	for speaker in speakers:
		speaker_field.add_item(speaker.get("Reference"), speaker.get("ID"))


#func _from_dict(dict):
	#id = dict.get("ID")
	#sentence = dict.get("Sentence")
	#speaker_id = dict.get("SpeakerID")
	#display_speaker_name = dict.get("DisplaySpeakerName")
	#display_variant = dict.get("DisplayVariant")
	#
	#if speaker_id >= character_drop_node.item_count:  # avoid falsy check
		#graph_node.speaker_id = 0
	#else:
		#character_drop_node.selected = speaker_id
	#display_speaker_name_node.text = display_speaker_name
	#sentence_edit_node.text = sentence
	#display_variant_node.text = display_variant

#
#func _on_character_drop_item_selected(index):
	#_on_node_property_change(["speaker_id"], [index])
