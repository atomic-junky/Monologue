extends Window


signal confirmed
signal denied
signal cancelled

const SAVE_PROMPT = "%s has been modified, save changes?"

@onready var prompt_label = $PanelContainer/VBox/PromptLabel
@onready var confirm_button = $PanelContainer/VBox/HBox/ConfirmButton
@onready var deny_button = $PanelContainer/VBox/HBox/DenyButton
@onready var cancel_button = $PanelContainer/VBox/HBox/CancelButton


func prompt_save(filename: String):
	if not is_node_ready():
		await ready
	
	prompt_label.text = SAVE_PROMPT % Util.truncate_filename(filename)
	show()


func _on_confirm_button_pressed():
	queue_free()
	confirmed.emit()


func _on_deny_button_pressed():
	queue_free()
	denied.emit()


func _on_cancel_button_pressed():
	queue_free()
	cancelled.emit()
