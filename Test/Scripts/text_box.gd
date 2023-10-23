extends Control


@onready var text_label = $Container/TextLabel
@onready var speaker_container = $Container/SpeakerContainer
@onready var speaker_label = $Container/SpeakerContainer/SpeakerLabel
@onready var next_indicator = $Container/Indicator/NextIndicator

var text = ""
var speaker_display = ""
var text_speed = 20
var complete: bool = false
var _display: bool = false

var tick = 0


func _ready():
	update()
	reset()


func _process(_delta):
	if complete:
		next_indicator.show()
	
	if not _display:
		return
	
	tick+=1
	
	if text_speed < 0 or text_label.visible_ratio >= 1:
		text_label.visible_characters = -1
		_display = false
		complete = true
		return
	
	if tick % text_speed:
		text_label.visible_characters += 1


func reset():
	next_indicator.hide()
	text_label.visible_characters = 0
	text_label.visible_ratio = 0
	_display = false
	complete = false
	tick = 0


func update():
	text_label.text = text
	
	if speaker_display == "_NARRATOR":
		speaker_container.hide()
		return
	
	speaker_container.show()
	speaker_label.text = speaker_display


func display():
	_display = true
