class_name TimerNode extends MonologueGraphNode


var amount := Property.new(SPINBOX, { "minimum": 0, "maximum": 120 })

@onready var timer_label = $TimerContainer/HBox/TimerLabel


func _ready():
	node_type = "NodeTimer"
	super._ready()


func _update():
	timer_label.text = str(amount.value)
	super._update()
