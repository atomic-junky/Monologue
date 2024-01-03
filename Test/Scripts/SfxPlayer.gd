extends AudioStreamPlayer2D

class_name SfxPlayer


var loop: bool = false

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
