class_name RerouteNode extends MonologueGraphNode


func _ready() -> void:
	node_type = "NodeReroute"
	super._ready()
	#get_titlebar_hbox().free()
	title = ""
	size.y = 0
	size.x = 0
