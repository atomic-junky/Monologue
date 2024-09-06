class_name AudioNode extends MonologueGraphNode


var loop   := Property.new(TOGGLE)
var volume := Property.new(SLIDER, { "suffix": "db", "minimum": -80, "maximum": 24, "step": 0.25 })
var pitch  := Property.new(SLIDER, { "default": 1, "minimum": 0, "maximum": 4, "step": 0.1 })
var audio  := Property.new(FILE, { "filters": FilePicker.AUDIO })

@onready var _audio_label = $MarginContainer/HBox/AudioLabel
@onready var _loop_label = $MarginContainer/HBox/LoopLabel


func _ready():
	node_type = "NodeAudio"
	super._ready()
	audio.connect("preview", _on_audio_preview)


func _on_audio_preview(audio_path: Variant):
	_audio_label.text = str(audio_path).get_file()


func _update():
	_audio_label.text = audio.value
	_loop_label.visible = loop.value
	super._update()
