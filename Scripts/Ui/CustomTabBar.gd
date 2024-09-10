extends TabBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for children in get_children(true):
		print(children.name)
