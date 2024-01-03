extends Node

class_name SfxLoaderInstance


func load_track(path: String, pitch: float = 1.0, volume: float = 0.0) -> SfxPlayer:
	var Player = SfxPlayer.new()
	
	if path != "":
		Player.pitch_scale = pitch
		Player.volume_db = volume
		var Stream: AudioStreamMP3 = AudioStreamMP3.new()
		var File: FileAccess = FileAccess.open(path, FileAccess.READ)
		if File != null:
			Stream.data = File.get_buffer(File.get_length())
			File.close()
		
		Player.stream = Stream
	else:
		print("SfxLoader: File not provided")
	
	add_child(Player)
	Player.play()
	return Player


func clear():
	for child in get_children():
		child.queue_free()
