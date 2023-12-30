extends Control


func load_scene(scene):
	var main_scene = scene.instantiate()
	
	get_tree().root.add_child(main_scene)
	
	queue_free()


func _on_return_to_editor_button_pressed():
	queue_free()

func _on_test_button_modern_pressed():
	var scene = preload("res://Test/Main.tscn")
	load_scene(scene)
