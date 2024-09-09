class_name OptionNode extends MonologueGraphNode


var option := Property.new(TEXT, { "minimum_size": Vector2(200, 60) })
var enable_by_default := Property.new(CHECKBOX)
var one_shot := Property.new(CHECKBOX)
var next_id = -1

@onready var count_label = $MarginContainer/VBox/CountLabel
@onready var preview_label = $MarginContainer/VBox/PreviewLabel


func _ready():
	node_type = "NodeOption"
	super._ready()
	option.connect("preview", _on_text_preview)
	get_titlebar_hbox().get_child(0).hide()


func get_graph_edit() -> MonologueGraphEdit:
	# for OptionNode, get_parent() returns ChoiceNode
	return get_parent().get_graph_edit()


func set_count(number: int):
	count_label.text = "Option %d" % number


func _from_dict(dict: Dictionary) -> void:
	option.value = dict.get("Sentence", "")
	enable_by_default.value = dict.get("Enable", false)
	next_id = dict.get("NextID", -1)
	super._from_dict(dict)


func _on_text_preview(text: Variant):
	preview_label.text = str(text)


func _to_next(dict: Dictionary, key: String = "NextID") -> void:
	dict[key] = next_id.value
