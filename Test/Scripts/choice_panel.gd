extends VBoxContainer

var choice_button_instance = preload("res://Test/Objects/choice_button.tscn")


func add_button(text, callback: Callable):
	var new_button: Button = choice_button_instance.instantiate()
	new_button.text = text
	new_button.tooltip_text = text
	
	new_button.pressed.connect(callback)
	
	add_child(new_button)

func clear():
	for child in get_children():
		child.queue_free()
