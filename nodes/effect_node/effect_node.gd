extends MonologueGraphNode


var effect_type  := Property.new(DROPDOWN, {}, "Shake")

var decay := Property.new(SPINBOX, { "step": 0.1 }, 0.8)
var strength := Property.new(SPINBOX, { "step": 0.1 }, 30.0)

var _control_groups = {
	"Shake": [decay, strength],
}


@onready var effect_type_label := $EffectContainer/HBox/EffectTypeLabel


func _ready() -> void:
	node_type = "NodeEffect"
	effect_type.callers["set_items"] = [[
		{ "id": 0, "text": "Shake" },
	]]
	effect_type.connect("preview", _show_group)
	effect_type.connect("preview", _update)
	
	super._ready()
	_show_group(effect_type.value)
	_update()


func _update(fx_type: Variant = effect_type.value):
	match fx_type:
		"Shake":
			effect_type_label.text = "Shake"
	
	super._update()


func _show_group(effect_type: Variant) -> void:
	for key in _control_groups.keys():
		for property in _control_groups.get(key):
			property.visible = key == effect_type
	title = node_type


func _get_field_groups() -> Array:
	return ["effect_type", {"Shake Settings": ["decay", "strength"]}]
