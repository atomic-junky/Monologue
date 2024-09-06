@icon("res://Assets/Icons/NodesIcons/Cog.svg")
class_name ActionNode extends MonologueGraphNode


var action := Property.new(LINE)
var arguments


func _ready():
	node_type = "NodeAction"
	super._ready()
