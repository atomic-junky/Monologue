extends Control


@export_file var load_scene: String
@export var min_display_time: float = 2.0
@export var after_blink_time: float = 1.0

@onready var timer = $tMinDisplayTime
@onready var eye = $CenterContainer/AnimatedSprite2D


func _ready() -> void:
	timer.start(min_display_time)
	ResourceLoader.load_threaded_request(load_scene)


func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(load_scene)
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and timer.is_stopped():
		var scene := ResourceLoader.load_threaded_get(load_scene)
		
		eye.play("blink")
		await eye.animation_finished
		await get_tree().create_timer(after_blink_time).timeout
		
		get_window().unresizable = false
		get_tree().change_scene_to_packed(scene)
