extends CenterContainer


@onready var searchbar = $SearchBar


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Show searchbar"):
		searchbar.visible = !searchbar.visible
		if searchbar.visible: searchbar.focus()
	
	if Input.is_key_pressed(KEY_ESCAPE):
		searchbar.hide()
