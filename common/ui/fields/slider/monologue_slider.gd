class_name MonologueSlider extends MonologueField


@export var default: float
@export var minimum: float
@export var maximum: float
@export var step: float
@export var suffix: String

@onready var control_label = $ControlLabel
@onready var display_label = $DisplayLabel
@onready var reset_button = $ResetButton
@onready var slider = $HSlider


func _ready():
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step


func set_label_text(text: String) -> void:
	control_label.text = text


func propagate(value: Variant) -> void:
	super.propagate(value)
	slider.value = value if (value is float or value is int) else default


func _on_drag_ended(value_changed: bool) -> void:
	if value_changed:
		field_updated.emit(slider.value)


func _on_reset() -> void:
	if slider.value != default:
		slider.value = default
		field_updated.emit(default)


func _on_value_changed(value: float) -> void:
	display_label.text = str(value) + suffix
