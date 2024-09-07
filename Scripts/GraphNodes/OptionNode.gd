class_name OptionNode extends MonologueGraphNode


var sentence  := Property.new(TEXT)
var enable    := Property.new(CHECKBOX)
var one_shot  := Property.new(CHECKBOX)

# special
var update_id := Property.new(LINE, { "copyable": true })
var next_id   := Property.new(LINE, {}, -1)

@onready var count_label = $MarginContainer/VBox/CountLabel
@onready var preview_label = $MarginContainer/VBox/PreviewLabel


func _ready():
	node_type = "NodeOption"
	super._ready()
	get_titlebar_hbox().get_child(0).hide()


func set_count(number: int):
	count_label.text = "Option %d" % number


func _to_next(dict: Dictionary, key: String = "NextID") -> void:
	dict[key] = next_id.value
