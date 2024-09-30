class_name SetterNode extends MonologueGraphNode


var set_type  := Property.new(DROPDOWN)
var option_id := Property.new(LINE)
var enable    := Property.new(TOGGLE)
var variable  := Property.new(DROPDOWN)
var operator  := Property.new(DROPDOWN, {}, "=")
var value     := Property.new(LINE)
var image     := Property.new(FILE, { "filters": FilePicker.IMAGE })
var time      := Property.new(SPINBOX, { "minimum": 0, "maximum": 120 })

var _control_groups = {
	"Option": [option_id, enable],
	"Variable": [variable, operator, value],
	"Background": [image],
	"Timer": [time],
}

@onready var _option_container = $OptionContainer
@onready var _option_id_label = $OptionContainer/HBox/OptionIdLabel
@onready var _bool_label = $OptionContainer/HBox/BoolLabel
@onready var _variable_container = $VariableContainer
@onready var _variable_label = $VariableContainer/HBox/VariableLabel
@onready var _operator_label = $VariableContainer/HBox/OperatorLabel
@onready var _value_label = $VariableContainer/HBox/ValueLabel
@onready var _background_container = $BackgroundContainer
@onready var _path_label = $BackgroundContainer/VBox/HBox/PathLabel
@onready var _preview_rect = $BackgroundContainer/VBox/PreviewRect
@onready var _timer_container = $TimerContainer
@onready var _timer_label = $TimerContainer/HBox/TimerLabel


func _ready() -> void:
	node_type = "NodeSetter"
	set_type.callers["set_items"] = [[
		{ "id": 0, "text": "Option"     },
		{ "id": 1, "text": "Variable"   },
		{ "id": 2, "text": "Background" },
		{ "id": 3, "text": "Timer"      },
	]]
	set_type.connect("change", func(old, new): _show_group(new))
	set_type.connect("preview", _show_group)
	option_id.connect("preview", _option_id_label.set_text)
	enable.connect("preview", func(e): _bool_label.text = str(e))
	
	variable.connect("preview", _variable_label.set_text)
	variable.connect("preview", _value_morph)
	operator.callers["set_items"] = [[
		{ "id": 0, "text": "="  },
		{ "id": 1, "text": "+=" },
		{ "id": 2, "text": "-=" },
		{ "id": 3, "text": "*=" },
		{ "id": 4, "text": "/=" },
	]]
	operator.connect("preview", _operator_label.set_text)
	operator.connect("shown", _value_morph)
	value.connect("preview", func(v): _value_label.text = str(v))
	
	image.setters["base_path"] = get_graph_edit().file_path
	image.connect("preview", _on_image_preview)
	time.connect("preview", func(t): _timer_label.text = str(t))
	super._ready()


func _default_text(new_value: Variant, default: String) -> String:
	return str(new_value) if new_value else default


func _from_dict(dict: Dictionary) -> void:
	super._from_dict(dict)
	_show_group(set_type.value)
	_value_morph(variable.value)


## Just a fun thing to do as a throwback to the old CustomAction.
func _get_emoji() -> String:
	match set_type.value:
		"Option":     return "❔ "
		"Variable":   return "⚙️ "
		"Background": return "🖼️ "
		"Timer":      return "⏱️ "
		_:            return ""


func _load_image():
	_path_label.text = image.value if image.value else "nothing"
	_preview_rect.hide()
	size.y = 0
	var base = image.setters.get("base_path")
	var path = Path.relative_to_absolute(image.value, base)
	
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img:
			_preview_rect.show()
			_preview_rect.texture = ImageTexture.create_from_image(img)
			_path_label.text = image.value.get_file()
		else:
			_preview_rect.hide()


func _on_image_preview(new_path: Variant) -> void:
	_path_label.text = str(new_path)
	_load_image()


func _show_group(setter_type: Variant) -> void:
	for key in _control_groups.keys():
		for property in _control_groups.get(key):
			property.visible = key == setter_type
	title = "%s%s" % [_get_emoji(), node_type]
	_update(setter_type)


func _value_morph(_selected_name: Variant = "") -> void:
	var selected_type = ""
	for data in get_graph_edit().variables:
		if data.get("Name") == variable.value:
			selected_type = data.get("Type")
	
	match selected_type:
		"Boolean":
			operator.invoke("disable_items", [[1, 2, 3, 4]])
			value.morph(TOGGLE)
		"Integer":
			operator.invoke("disable_items", [[]])
			value.morph(SPINBOX)
		"String":
			operator.invoke("disable_items", [[1, 2, 3, 4]])
			value.morph(LINE)


func _update(setter_type: Variant = set_type.value) -> void:
	_option_container.visible = setter_type == "Option"
	_option_id_label.text = _default_text(option_id.value, "option id")
	_bool_label.text = _default_text(enable.value, "false")
	
	_variable_container.visible = setter_type == "Variable"
	_variable_label.text = _default_text(variable.value, "variable")
	_operator_label.text = _default_text(operator.value, "operator")
	_value_label.text = _default_text(value.value, "value")
	
	_background_container.visible = setter_type == "Background"
	_path_label.text = _default_text(str(image.value).get_file(), "nothing")
	_load_image()
	
	_timer_container.visible = setter_type == "Timer"
	_timer_label.text = str(int(time.value))
	
	variable.callers["set_items"] = \
			[get_graph_edit().variables, "Name", "ID", "Type"]
	super._update()
