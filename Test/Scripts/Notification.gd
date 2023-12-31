extends PanelContainer


@onready var timeleft = $VBoxContainer/TimeLeft


func _ready():
	hide()


func debug(text: String):
	show()
	$VBoxContainer/MarginContainer/RichTextLabel.text = "[color=e5b65e][DEBUG][/color] " + text
	timeleft.custom_minimum_size.x = size.x
	var tween = get_tree().create_tween()
	tween.tween_property(timeleft, "custom_minimum_size:x", 0, 7.5)
	tween.tween_callback(hide)
