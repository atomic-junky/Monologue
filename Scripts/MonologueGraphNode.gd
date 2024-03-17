class_name MonologueGraphNode

extends GraphNode


var id: String = UUID.v4()
var node_type: String = "NodeUnknown"

func _from_dict(_dict: Dictionary):
	pass

func _to_dict():
	pass

func _update(_panel = null):
	pass

func _common_update(_panel = null):
	size.y = 0
	
	if _panel:
		id = _panel.id

func _connect_to_panel(sgnl):
	sgnl.connect(_update)
	sgnl.connect(_common_update)
