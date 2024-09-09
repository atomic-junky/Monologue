@icon("res://Assets/Icons/NodesIcons/Sentence.svg")

class_name SentenceNode extends MonologueGraphNode


@onready var text_label = $MainContainer/TextLabelPreview

var loaded_text = ""
var sentence = ""
var speaker_id = 0
var display_speaker_name = ""
var display_variant = ""
var voiceline_path = ""


func _ready():
	node_type = "NodeSentence"
	title = node_type


func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_id_node[0].id if next_id_node else -1,
		"Sentence": sentence,
		"SpeakerID": speaker_id,
		"DisplaySpeakerName": display_speaker_name,
		"DisplayVariant": display_variant,
		"VoicelinePath": voiceline_path,
		"EditorPosition": {
			"x": position_offset.x,
			"y": position_offset.y
		}
	}


func _from_dict(dict: Dictionary):
	id = dict.get("ID")
	sentence = dict.get("Sentence")
	speaker_id = dict.get("SpeakerID")
	display_speaker_name = dict.get("DisplaySpeakerName")
	display_variant = dict.get("DisplayVariant", "")
	voiceline_path = dict.get("VoicelinePath", "")
	
	_update()
	
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")


func _update(panel: SentenceNodePanel = null):
	if panel != null:
		sentence = panel.sentence
		speaker_id = panel.speaker_id
		display_speaker_name = panel.display_speaker_name
		display_variant = panel.display_variant
		voiceline_path = panel.voiceline_path
	
	text_label.text = sentence
