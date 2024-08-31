class_name Header extends HFlowContainer


var file_callback: Callable = GlobalVariables.empty_callback

@onready var add_menu: PopupMenu = $MenuBar/Add
@onready var save_button: Button = $Save
@onready var save_notification: Label = $SaveNotification
@onready var save_progress: ProgressBar = %SaveProgressBar
@onready var save_timer: Timer = $SaveNotification/Timer
@onready var test_button: Button = $TestBtnContainer/Test


func _ready() -> void:
	hide_save_notification()


func start_save_progress(max_value: int) -> void:
	save_progress.max_value = max_value
	save_progress.value = 0
	save_progress.show()
	save_notification.hide()
	save_timer.stop()
	save_button.hide()
	test_button.hide()


func increment_save_progress() -> void:
	save_progress.value += 1


func show_save_notification(duration: float = 1.5) -> void:
	if duration > 0:
		save_notification.show()
		save_timer.start(duration)
	else:
		hide_save_notification()


func hide_save_notification() -> void:
	save_notification.hide()
	save_progress.hide()
	save_button.show()
	test_button.show()


func _on_add_id_pressed(id: int) -> void:
	var node_type = add_menu.get_item_text(id)
	GlobalSignal.emit("add_graph_node", [node_type])


func _on_file_id_pressed(id: int) -> void:
	match id:
		0: GlobalSignal.emit("open_file_request", [file_callback, ["*.json"]])
		1: GlobalSignal.emit("save_file_request", [file_callback, ["*.json"]])
		3: GlobalSignal.emit("show_current_config")
		4: GlobalSignal.emit("test_trigger")


func _on_help_id_pressed(id: int) -> void:
	match id:
		0: OS.shell_open("https://github.com/atomic-junky/Monologue/wiki")


func _on_save_pressed():
	GlobalSignal.emit("save")
