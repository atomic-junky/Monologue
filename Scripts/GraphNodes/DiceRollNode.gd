@icon("res://Assets/Icons/NodesIcons/DiceRoll.svg")
class_name DiceRollNode extends MonologueGraphNode


var target := Property.new(SPINBOX,
		{ "minimum": 0, "maximum": 100, "suffix": "%" }, 0)

@onready var pass_value = $PassContainer/PassValue
@onready var fail_value = $FailContainer/FailValue


func _ready():
	node_type = "NodeDiceRoll"
	super._ready()
	target.connect("preview", _update)
	_update()


func _load_connections(data: Dictionary, key: String = "PassID") -> void:
	super._load_connections(data, key)
	var fail_id = data.get("FailID")
	if fail_id is String:
		var fail_node = get_parent().get_node_by_id(fail_id)
		get_parent().connect_node(name, 1, fail_node.name, 0)


func _to_next(dict: Dictionary, key: String = "PassID") -> void:
	var pass_id_node = get_graph_edit().get_all_connections_from_slot(name, 0)
	dict[key] = pass_id_node[0].id.value if pass_id_node else -1
	
	var fail_id_node = get_graph_edit().get_all_connections_from_slot(name, 1)
	dict["FailID"] = fail_id_node[0].id.value if fail_id_node else -1


func _update(new_value: Variant = target.value):
	pass_value.text = "(" + str(new_value) + "%)"
	fail_value.text = "(" + str(100 - new_value) + "%)"
	super._update()
