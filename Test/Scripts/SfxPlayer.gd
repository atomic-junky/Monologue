class_name SfxPlayer extends AudioStreamPlayer2D


var loop: bool = false
var id: int

func _init():
	connect("finished", _on_finished)

func _on_finished():
	if loop:
		play()
		return
		
	queue_free()

func pause():
	stream_paused = true

func unpause():
	stream_paused = false

func unload():
	if stream != null:
		stream = null
