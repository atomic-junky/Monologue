class_name BackgroundNode extends MonologueGraphNode


var background_type  := Property.new(DROPDOWN, {}, "Image")
var image := Property.new(FILE, { "filters": FilePicker.IMAGE })
var custom_scene := Property.new(FILE, { "filters": ["*.tscn"] })
var transition := Property.new(DROPDOWN, {}, "No Transition")
var duration := Property.new(SPINBOX, { "step": 0.1 }, 0.0)

var _control_groups = {
	"Image": [image],
	"Custom Scene": [custom_scene]
}

@onready var _path_label = $BackgroundContainer/VBox/HBox/PathLabel
@onready var _preview_rect = $BackgroundContainer/VBox/PreviewRect


func _ready():
	node_type = "NodeBackground"
	background_type.callers["set_items"] = [[
		{ "id": 0, "text": "Image"        },
		{ "id": 1, "text": "Custom Scene" },
	]]
	background_type.connect("preview", _show_group)
	background_type.connect("preview", _update)
	transition.callers["set_items"] = [[
		{ "id": 0, "text": "No Transition"},
		{ "id": 1, "text": "Push Down"    },
		{ "id": 1, "text": "Push Left"    },
		{ "id": 1, "text": "Push Right"   },
		{ "id": 1, "text": "Push Up"      },
		{ "id": 1, "text": "Simple Fade"  },
	]]
	transition.connect("preview", _update)
	
	super._ready()
	image.setters["base_path"] = get_parent().file_path
	image.connect("preview", _on_path_preview)
	_show_group(background_type.value)
	_update()


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


func _on_path_preview(path: Variant):
	_path_label.text = str(path).get_file()
	_load_image.call_deferred()


func _show_group(setter_type: Variant) -> void:
	for key in _control_groups.keys():
		for property in _control_groups.get(key):
			property.visible = key == setter_type
	title = node_type


func _update(_bg_type: Variant = background_type.value):
	_path_label.text = image.value
	_load_image()
	super._update()


func _get_field_groups() -> Array:
	return ["background_type", "image", "custom_scene", {"Transition": ["transition", "duration"]}]
