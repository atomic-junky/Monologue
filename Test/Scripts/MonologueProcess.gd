class_name MonologueProcess
extends Control


var dir_path

var active_voiceline: SfxPlayer
var root_node_id: String
var node_list: Array
var characters: Array
var variables: Array
var events: Array

var next_id
var fallback_id

var rng = RandomNumberGenerator.new()
var timer = Timer.new()

signal monologue_node_reached(raw_node: Dictionary)
signal monologue_sentence(sentence: String, speaker: String, speaker_name: String)
signal monologue_new_choice(options: Array[Dictionary])
signal monologue_option_choosed(raw_option: Dictionary)
signal monologue_event_triggered(raw_event: Dictionary)
signal monologue_end(raw_end)
signal monologue_play_audio(path: String, stream)
signal monologue_update_background(path: String, background)
signal monologue_custom_action(raw_action: Dictionary)
signal monologue_timer_started(wait_time: float)


enum NotificationLevel {INFO, DEBUG, WARN, ERROR, CRITICAL}


func _init():
	print("[INFO] Monologue Process initiated")
	monologue_node_reached.connect(_process_node)
	monologue_end.connect(_default_end_process)
	timer.one_shot = true
	timer.connect("timeout", next)
	connect("ready", add_child.bind(timer))


func load_dialogue(dialogue_name, custom_start_id = null):
	var path = dialogue_name + ".json"
	dir_path = path.replace("/", "\\").split("\\")
	dir_path.remove_at(len(dir_path)-1)
	dir_path = "\\".join(dir_path)
	assert(FileAccess.file_exists(path), "Can't find dialogs file")
	
	var file = FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	assert(data.has("RootNodeID"), "Invalid json file, can't find 'RootNodeID'")
	assert(data.has("ListNodes"), "Invalid json file, can't find 'ListNodes'")
	assert(data.has("Characters"), "Invalid json file, can't find 'Characters'")
	assert(data.has("Variables"), "Invalid json file, can't find 'Variables'")
	
	root_node_id = data.get("RootNodeID")
	node_list = data.get("ListNodes")
	characters = data.get("Characters")
	variables = Util.merge_dict(data.get("Variables"), variables, "Name")
	events = node_list.filter(func(n): return n.get("$type") == "NodeEvent")
	
	next_id = custom_start_id
	if not custom_start_id or custom_start_id is not String:
		next_id = root_node_id
	
	print("[INFO] Dialogue " + path + " loaded")


func next():
	timer.stop()  # prevent timer from counting down on skip
	if active_voiceline and is_instance_valid(active_voiceline):
		active_voiceline.queue_free()  # stop voiceline if still playing
	active_voiceline = null
	
	# Check for an event
	for event in events:
		var condition = event.get("Condition")
		var variable = get_variable(condition.get("Variable"))
		if variable == null:
			# used to call _notify() here but removed, gets called too often!
			continue
		
		var v_val = variable.get("Value")
		var c_val = condition.get("Value")
		var condition_pass: bool = false
		match condition.get("Operator"):
			"==":
				condition_pass = v_val == c_val
			">=":
				condition_pass = v_val >= c_val
			"<=":
				condition_pass = v_val <= c_val
			"!=":
				condition_pass = v_val != c_val
		if condition_pass:
			monologue_event_triggered.emit(event)
			fallback_id = next_id
			next_id = event.get("NextID")
			events.erase(event)
	
	if next_id is float and next_id == -1:
		if fallback_id:
			next_id = fallback_id
			fallback_id = null
		else:
			monologue_end.emit(null)
	
	var node = find_node_from_id(next_id)
	if node:
		monologue_node_reached.emit(node)


func _process_node(node: Dictionary):
	match node.get("$type"):
		"NodeRoot":
			next_id = node.get("NextID")
			next()
			return
		"NodeBridgeIn":
			next_id = node.get("NextID")
			next()
			return
		"NodeBridgeOut":
			next_id = node.get("NextID")
			next()
			return
		"NodeSentence":
			next_id = node.get("NextID")
			
			var processed_sentence = process_conditional_text(node.get("Sentence"))
			var speaker_name = node.get("DisplaySpeakerName") if node.get("DisplaySpeakerName") else get_speaker(node.get("SpeakerID"))
			
			var voiceline_path = node.get("VoicelinePath", "")
			if voiceline_path != "":
				if voiceline_path.is_relative_path():
					voiceline_path = dir_path + "/" + voiceline_path
				var player = SfxLoader.load_track(voiceline_path)
				
				if player is Error:
					_notify(NotificationLevel.ERROR, "Voiceline not found!")
				else:
					active_voiceline = player
			
			monologue_sentence.emit(
				processed_sentence,
				get_speaker(node.get("SpeakerID")),
				speaker_name
			)
		"NodeChoice":
			var options: Array = []
			for option_id in node.get("OptionsID"):
				var option = find_node_from_id(option_id)
				if not option:
					_notify(NotificationLevel.WARN, "Can't find option with id: " + option_id)
					continue
				if option.get("Enable") == false:
					continue
				
				options.append(option)
			monologue_new_choice.emit(options)
		"NodeDiceRoll":
			rng.randomize()
			var roll = rng.randi_range(0, 100)
			if roll <= node.get("Target"):
				next_id = node.get("PassID")
			else:
				next_id = node.get("FailID")
		
			next()
			return
		"NodeAction":
			next_id = node.get("NextID")
			
			var raw_action = node.get("Action")
			match raw_action.get("$type"):
				"ActionOption":
					var option: Dictionary = find_node_from_id(raw_action.get("OptionID"))
					
					if option == null:
						_notify(NotificationLevel.WARN, "Can't find option. Skipping.")
						next()
						return
					
					option["Enable"] = raw_action.get("Value")
				"ActionVariable":
					var variable = get_variable(raw_action.get("Variable"))
					
					if variable == null:
						print("[WARNING] Can't find variable. Skipping")
						next()
						return
					
					match raw_action.get("Operator"):
						"=":
							variable["Value"] = raw_action.get("Value")
						"+":
							variable["Value"] += raw_action.get("Value")
						"-":
							variable["Value"] -= raw_action.get("Value")
						"*":
							variable["Value"] *= raw_action.get("Value")
						"/":
							if raw_action.get("Value") != 0:
								variable["Value"] /= raw_action.get("Value")
							else:
								print("[WARNING] Can't divide by value 0")
				"ActionCustom":
					match raw_action.get("CustomType"):
						"PlayAudio":
							var full_path = dir_path + "\\assets\\audios\\" + raw_action.get("Value")
							var sound = null
							if FileAccess.file_exists(full_path):
								var player = SfxLoader.load_track(full_path, raw_action.get("Pitch"), raw_action.get("Volume"))
								if player is Error:
									_notify(NotificationLevel.ERROR, "[ERROR] Audio file not found!")
								else:
									player.loop = raw_action.get("Loop")
							
							monologue_play_audio.emit(raw_action.get("Value"), sound)
						"UpdateBackground":
							var bg = Image.new()
							var texture = null
							
							var full_path = dir_path + "\\assets\\backgrounds\\" + raw_action.get("Value")
							if FileAccess.file_exists(full_path):
								var err = bg.load(full_path)
								if err != OK:
									_notify(NotificationLevel.WARN, "Failed to load background (" + raw_action.get("Value") + ")")
								else:
									texture = ImageTexture.create_from_image(bg)
							
							monologue_update_background.emit(raw_action.get("Value"), texture)
						"Other":
							monologue_custom_action.emit(raw_action)
				"ActionTimer":
					var time_to_wait = raw_action.get("Value", 0.0)
					if not is_inside_tree():
						_notify(NotificationLevel.WARN, "MonologueProcess is not inside tree and can't create a timer...")
					else:
						timer.start(time_to_wait)
						monologue_timer_started.emit(time_to_wait)
						return
					
			next()
			return
		"NodeCondition":
			var condition = node.get("Condition")
			var variable = get_variable(condition.get("Variable"))
			
			var if_nid = node.get("IfNextID")
			var else_nid = node.get("ElseNextID")
			var v_val = variable.get("Value")
			var c_val = condition.get("Value")
			next_id = if_nid
			
			if variable == null:
				_notify(NotificationLevel.WARN, "Can't find variable. Skipping.")
				next()
				return
			
			match condition.get("Operator"):
				"==":
					next_id = if_nid if v_val == c_val else else_nid
				">=":
					next_id = if_nid if v_val >= c_val else else_nid
				"<=":
					next_id = if_nid if v_val <= c_val else else_nid
				"!=":
					next_id = if_nid if v_val != c_val else else_nid
			
			next()
			return
		"NodeEndPath":
			monologue_end.emit(node)

func find_node_from_id(id):
	if not id is String:
		return null
		
	var nodes = node_list.filter(func (node): return node.get("ID") == id)
	if nodes.size() <= 0:
		return null
	return nodes[0]

func get_speaker(id: int) -> String:
	var speaker = characters.filter(func (c): return c["ID"] == id)
	if speaker.size() <= 0:
		return ""
	return speaker[0]["Reference"]

func get_variable(var_name: String):
	var variable = variables.filter(func (v): return v.get("Name") == var_name)
	
	if variable.size() <= 0:
		return null
	return variable[0]

func process_conditional_text(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("(?<=\\{{)(.*?)(?=\\}})")
	var results = regex.search_all(text)
	if not results:
		return text
	
	for r in results:
		var condition: String = r.get_string()
		var original_condition: String = "{{" + condition + "}}"
		condition = condition.strip_edges(true, true)
		
		var if_position = condition.find("if")
		var then_position = condition.find("then")
		var else_position = condition.find("else")
		
		var var_name = condition.substr(if_position+3, then_position - (if_position+3)).strip_edges(true, true)
		var then_name = condition.substr(then_position+5, else_position - (then_position+5)).strip_edges(true, true).trim_prefix("\"").trim_suffix("\"")
		var else_name = condition.substr(else_position+5).strip_edges(true, true).trim_prefix("\"").trim_suffix("\"")
		
		var variable = get_variable(var_name)
		
		if not variable:
			_notify(NotificationLevel.ERROR, "Can't find the variable " + var_name)
		
		if variable.get("Type") != "Boolean":
			_notify(NotificationLevel.ERROR, "The variable can only be of type Boolean (not " + variable.get("Type")  + ")")
			return text
		
		if variable.get("Value") == true:
			text = text.replace(original_condition, then_name)
			continue
		text = text.replace(original_condition, else_name)
		
	return text


func _default_end_process(raw_end):
	if raw_end:
		var next_story = raw_end.get("NextStoryName").trim_suffix(".json")
		if next_story.is_relative_path():
			next_story = dir_path + "/" + next_story
		
		if FileAccess.file_exists(next_story + ".json"):
			load_dialogue(next_story)
			next()
			return true
	return false


func option_selected(option):
	monologue_option_choosed.emit(option)
	
	if option == null:
		_notify(NotificationLevel.CRITICAL, "Can't find option. Unexpected exit.")
		monologue_end.emit(null)
		return
	
	next_id = option.get("NextID")
	
	if option.get("OneShot") == true:
		option["Enable"] = false
	
	next()


# Maybe call this function _log or smth
func _notify(_level: NotificationLevel, _text: String):
	pass  # overridden by Main.gd
