extends PanelContainer


const DEFAULT_TIME = 7.5

var tween: Tween

@onready var timeleft = $VBoxContainer/TimeLeft
@onready var label = $VBoxContainer/MarginContainer/RichTextLabel


func _ready():
	hide()


func debug(text: String, time = DEFAULT_TIME):
	notify(text, "DEBUG", Color("e5b65e"), time)


func info(text: String, time = DEFAULT_TIME):
	notify(text, "INFO", Color.DODGER_BLUE, time)


func notify(text, tag, color, time):
	label.text = "[color=%s][%s][/color] %s" % [color.to_html(false), tag, text]
	timeleft.custom_minimum_size.x = size.x
	timeleft.get_theme_stylebox("panel").bg_color = color
	
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(timeleft, "custom_minimum_size:x", 0, time)
	tween.tween_callback(hide)
	show()
