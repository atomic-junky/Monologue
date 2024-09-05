## Horizontal slider with reset controls.
class_name MonologueSlider extends MonologueField


const DISPLAY_COLOR = Color("929292")
const RESET_COLOR = Color("c42e40")

var slider: HSlider
var display_label: Label
var display_suffix: String
var reset_button: Button
var reset_value: float


func build() -> MonologueField:
	# create display label first
	display_label = Label.new()
	display_label.custom_minimum_size.x = 70
	display_label.add_theme_color_override("font_color", DISPLAY_COLOR)
	
	# create slider
	slider = HSlider.new()
	slider.custom_minimum_size.x = 100
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.min_value = -100
	slider.max_value = 100
	slider.connect("value_changed", _update_display_label)
	slider.connect("drag_ended", update_value)
	value = value  # reassign to trigger set_value() for newly created slider
	hbox.add_child(slider, true)
	hbox.add_child(display_label, true)
	
	# create reset button
	reset_button = Button.new()
	reset_button.text = "reset"
	reset_button.flat = true
	reset_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset_button.add_theme_color_override("font_color", RESET_COLOR)
	reset_button.connect("pressed", reset)
	hbox.add_child(reset_button)
	
	return self


## Specifies what slider value to reset to when reset button is pressed.
func default(number: float) -> MonologueSlider:
	reset_value = number
	return self


func limit(minimum: float, maximum: float, step: float) -> MonologueSlider:
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	return self


func reset() -> void:
	update_value(reset_value)


func set_value(new_value: Variant) -> void:
	var number = new_value if new_value is float or new_value is int else 0.0
	super.set_value(number)
	if slider:
		slider.value = number  # triggers "value_changed" signal here


func suffix(text: String) -> MonologueSlider:
	display_suffix = text
	return self


func _update_display_label(new_value: float):
	display_label.text = str(new_value) + display_suffix
