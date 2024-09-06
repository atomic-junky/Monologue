class_name BackgroundNode extends MonologueGraphNode


var image := Property.new(FILE, { "filters": FilePicker.IMAGE })

@onready var _path_label = $MarginContainer/VBox/HBox/PathLabel
@onready var _preview_rect = $MarginContainer/VBox/PreviewRect


func _ready():
	node_type = "NodeBackground"
	super._ready()
	image.setters["base_path"] = get_parent().file_path
	image.connect("preview", _on_path_preview)


func _load_image():
	var base = image.setters.get("base_path")
	var path = Path.relative_to_absolute(image.value, base)
	
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img:
			_preview_rect.show()
			_preview_rect.texture = ImageTexture.create_from_image(img)
		else:
			_preview_rect.hide()


func _on_path_preview(path: Variant):
	_path_label.text = str(path).get_file()
	_load_image()


func _update():
	_path_label.text = image.value
	_load_image()
	super._update()
