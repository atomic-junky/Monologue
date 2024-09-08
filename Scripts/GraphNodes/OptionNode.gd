class_name OptionNode extends MonologueGraphNode


var sentence  := Property.new(TEXT)
var enable    := Property.new(CHECKBOX)
var one_shot  := Property.new(CHECKBOX)
var next_id    = -1

@onready var count_label = $MarginContainer/VBox/CountLabel
@onready var preview_label = $MarginContainer/VBox/PreviewLabel


func _ready():
	node_type = "NodeOption"
	super._ready()
	sentence.connect("preview", _on_text_preview)
	get_titlebar_hbox().get_child(0).hide()


func set_count(number: int):
	count_label.text = "Option %d" % number


func _from_dict(dict: Dictionary) -> void:
	super._from_dict(dict)
	id = dict.get("ID")
	next_id = dict.get("NextID")


func _on_text_preview(text: Variant):
	preview_label.text = str(text)


func _to_next(dict: Dictionary, key: String = "NextID") -> void:
	dict[key] = next_id.value
