extends TabBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for children in get_children(true):
		print(children.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
