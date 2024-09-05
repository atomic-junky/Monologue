@icon("res://Assets/Icons/NodesIcons/Sentence.svg")
class_name SentenceNode extends MonologueGraphNode


var speaker_id = 0
var display_speaker_name = ""
var display_variant = ""
var sentence = ""
var voiceline_path = ""

@onready var sentence_preview = $MainContainer/TextLabelPreview


func _ready():
	node_type = "NodeSentence"
	title = node_type


func get_fields() -> Array[MonologueField]:
	var filters = ["*.mp3", "*.ogg", "*.wav"]
	return [
		MonologueOptionButton.new("speaker_id",
				"SpeakerID", speaker_id)
				.label("Speaker")
				.build()
				.set_items(get_parent().speakers, "Reference", "ID"),
		
		MonologueLineEdit.new("display_speaker_name",
				"DisplaySpeakerName", display_speaker_name)
				.sublabel("Display Name")
				.build(),
		
		MonologueLineEdit.new("display_variant",
				"DisplayVariant", display_variant)
				.sublabel("Display Variant")
				.build(),
		
		MonologueTextEdit.new("sentence",
				"Sentence", sentence)
				.label("Sentence")
				.build()
				.preview(sentence_preview),
		
		MonologueField.new("voiceline_path",
				"VoicelinePath", voiceline_path)
				.label("Voiceline")
				.scene(GlobalVariables.FILE_EDIT, "new_file_path",
					"_on_text_submitted", ["base_file_path", "filters"],
					[get_parent().file_path, filters]),
	]


func _update(_panel = null):
	sentence_preview.text = sentence
