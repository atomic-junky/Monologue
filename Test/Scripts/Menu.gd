extends Control


var _from_node_id = null


func _ready():
	%CustomIDLabel.hide()
	if _from_node_id != null:
		%CustomIDLabel.text = "(custom start node: " + _from_node_id + ")"
		%CustomIDLabel.show()

func load_scene(scene):
	var main_scene = scene.instantiate()
	main_scene._from_node_id = _from_node_id
	
	get_tree().root.add_child(main_scene)
	
	queue_free()


func _on_return_to_editor_button_pressed():
	queue_free()

func _on_test_button_modern_pressed():
	var scene = preload("res://Test/Main.tscn")
	load_scene(scene)
