class_name SfxLoaderInstance extends Node


func load_track(path: String, pitch: float = 1.0, volume: float = 0.0, id: String = "") -> Variant:
	var player = SfxPlayer.new()
	
	if path != "":
		player.pitch_scale = pitch
		player.volume_db = volume
		player.id = id
		var stream: AudioStreamMP3 = AudioStreamMP3.new()
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file != null:
			stream.data = file.get_buffer(file.get_length())
			file.close()
		else:
			return ERR_FILE_NOT_FOUND
		
		player.stream = stream
	else:
		return ERR_INVALID_PARAMETER
	
	add_child(player)
	player.play()
	return player


func clear():
	for child in get_children():
		child.queue_free()
