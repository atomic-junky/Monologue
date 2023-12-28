class_name MonologueGraphNode

extends GraphNode


var id: String = UUID.v4()
var node_type: String = "NodeUnknown"

func _from_dict(dict: Dictionary):
	pass

func _to_dict():
	pass

func _update(panel = null):
	pass

func _connect_to_panel(sgnl):
	sgnl.connect(_update)
