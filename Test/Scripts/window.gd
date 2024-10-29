class_name TestWindow extends Window


@onready var test_instance := preload("res://Test/Menu.tscn")

var file_path: String
var from_node: String


func _init(path: String, _from_node: String) -> void:
	file_path = path
	from_node = _from_node


func _ready() -> void:
	hide()
	close_requested.connect(_on_close_requested)
	size = Vector2(1440, 810)
	force_native = true
	transient = true
	
	var test_scene = test_instance.instantiate()
	test_scene.from_node = from_node
	test_scene.file_path = file_path
	add_child(test_scene)
	
	move_to_center.call_deferred()
	show()


func _on_close_requested() -> void:
	queue_free()
