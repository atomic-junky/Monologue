extends HBoxContainer

var choice_button_instance = preload("res://Test/Objects/choice_button.tscn")

@onready var left_container = $LeftContainer
@onready var right_container = $RightContainer


func add_button(text, callback: Callable):
	var new_button: Button = choice_button_instance.instantiate()
	new_button.text = text
	new_button.tooltip_text = text
	
	new_button.pressed.connect(callback)
	
	if left_container.get_child_count() > right_container.get_child_count():
		right_container.add_child(new_button)
	else:
		left_container.add_child(new_button)

func clear():
	for child in left_container.get_children():
		left_container.remove_child(child)
		
	for child in right_container.get_children():
		right_container.remove_child(child)
