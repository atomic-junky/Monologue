class_name CharacterNode extends MonologueGraphNode


var character       := Property.new(DROPDOWN, { "store_index": true })
var action_type     := Property.new(DROPDOWN, {}, "Join" )

var _position       := Property.new(DROPDOWN, {}, "Left")
var _z_index        := Property.new(SPINBOX, { "step": 1 }, 0)
var mirrored        := Property.new(TOGGLE, {}, false)

var _control_groups = {
	"Join": [_z_index, _position, mirrored],
	"Leave": [],
	"Update": [_z_index, _position, mirrored],
}

@onready var action_type_label := $CharacterContainer/HBoxContainer/ActionTypeLabel
@onready var display_container := $CharacterContainer/HBoxContainer/DisplayContainer
@onready var position_label := $CharacterContainer/HBoxContainer/DisplayContainer/PositionLabel


func _ready():
	node_type = "NodeCharacter"
	action_type.callers["set_items"] = [[
		{ "id": 0, "text": "Join"  },
		{ "id": 1, "text": "Leave" },
		{ "id": 2, "text": "Update" },
	]]
	action_type.connect("preview", _show_group)
	action_type.connect("preview", _update)
	
	_position.callers["set_items"] = [[
		{ "id": 0, "text": "Left"  },
		{ "id": 1, "text": "Center" },
		{ "id": 2, "text": "Right" },
	]]
	_position.connect("preview", _update)
	
	super._ready()
	_show_group(action_type.value)
	_update()


func _update(value: Variant = null) -> void:
	super._update()
	await get_tree().process_frame
	
	var action: Variant = action_type.value
	character.callers["set_items"] = [get_graph_edit().speakers, "Reference", "ID"]
	
	display_container.visible = action != "Leave"
	action_type_label.text = action
	position_label.text = _position.value
	


func _show_group(action_type: Variant) -> void:
	for key in _control_groups.keys():
		for property in _control_groups.get(key):
			property.visible = false
	
	for key in _control_groups.keys():
		for property in _control_groups.get(key):
			if key == action_type:
				property.visible = true
	title = node_type


func _get_field_groups() -> Array:
	return ["character", "action_type", {"Display Settings": ["_z_index", "_position", "mirrored"]}]
