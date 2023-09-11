extends Control


func _on_new_game_button_pressed():
	var main_instance = preload("res://Test/Main.tscn")
	var main_scene = main_instance.instantiate()
	
	get_tree().root.add_child(main_scene)
	
	queue_free()


func _on_return_to_editor_button_pressed():
	queue_free()
