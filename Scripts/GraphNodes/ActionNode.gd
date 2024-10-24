@icon("res://Assets/Icons/NodesIcons/Cog.svg")
class_name ActionNode extends MonologueGraphNode


@export var arg_box: VBoxContainer
@export var action_label: Label
@export var no_args_label: Label

var action    := Property.new(LINE)
var arguments := Property.new(LIST, {}, [])
var _argument_references = []


func _ready():
	node_type = "NodeAction"
	super._ready()
	
	action.connect("preview", _set_action_text)
	arguments.setters["add_callback"] = add_argument
	arguments.setters["get_callback"] = get_arguments
	arguments.connect("preview", load_arguments)


func add_argument(data: Dictionary = {}) -> MonologueArgument:
	var argument = MonologueArgument.new(self)
	if data:
		argument._from_dict(data)
	argument.index = _argument_references.size()
	_argument_references.append(argument)
	return argument


func get_arguments():
	return _argument_references


func load_arguments(new_argument_list: Array):
	_argument_references.clear()
	for argument in new_argument_list:
		add_argument(argument)
	arguments.value = new_argument_list
	_update.call_deferred()


func _from_dict(dict: Dictionary) -> void:
	for key in dict.keys():
		var property = get(key.to_snake_case())
		if property is Property:
			property.value = dict.get(key)
	
	_load_position(dict)
	load_arguments(arguments.value)


func _set_action_text(new_text: String = action.value) -> void:
	action_label.text = new_text if new_text else "custom action"


func _update() -> void:
	_set_action_text()
	no_args_label.visible = _argument_references.is_empty()
	for child in arg_box.get_children():
		arg_box.remove_child(child)
		child.queue_free()
	
	for i in range(_argument_references.size()):
		arguments.value[i]["Value"] = _argument_references[i].value.value
		_argument_references[i].create_representation(arg_box)
	super._update()
