## UI control which allow the user to edit a graph node [MonologueProperty].
class_name MonologueField extends Control


## Emitted when the field's value is changed but not yet committed.
@warning_ignore("unused_signal")
signal field_changed(value: Variant)

## Emitted when the field's value is updated/comitted by user input.
@warning_ignore("unused_signal")
signal field_updated(value: Variant)


## Called by node panel to set field label text, if applicable.
func set_label_text(_text: String) -> void:
	pass


## Set the field's label visibility.
func set_label_visible(_can_see: bool) -> void:
	pass


## Meant to propagate the value set in [MonologueProperty] to this Field.
## This method does not emit [signal field_updated].
func propagate(_value: Variant) -> void:
	pass
