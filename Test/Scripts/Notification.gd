extends PanelContainer


@onready var timeleft = $VBoxContainer/TimeLeft


func _ready():
	hide()


func notify(text: String):
	show()
	$VBoxContainer/MarginContainer/RichTextLabel.text = text
	timeleft.custom_minimum_size.x = size.x
	var tween = get_tree().create_tween()
	tween.tween_property(timeleft, "custom_minimum_size:x", 0, 7.5)
	tween.tween_callback(hide)


func info(text: String):
	notify("[color=579144][INFO][/color] " + text)


func debug(text: String):
	notify("[color=5e8de6][DEBUG][/color] " + text)


func warn(text: String):
	notify("[color=e5b65e][WARN][/color] " + text)


func error(text: String):
	notify("[color=d19c9d][ERROR][/color] " + text)


func critical(text: String):
	notify("[color=d19c9d][CRITICAL][/color] " + text)
