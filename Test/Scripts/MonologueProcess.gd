class_name MonologueProcess
extends Control


signal monologue_node_reached(raw_node: Dictionary)
signal monologue_event_triggered(raw_event: Dictionary)
signal monologue_sentence(text: String, display_name: String, speaker: String)
signal monologue_new_choice(options: Array[Dictionary])
signal monologue_option_chosen(raw_option: Dictionary)
signal monologue_end(raw_end: Dictionary)
signal monologue_play_audio(path: String, player: AudioStreamPlayer2D)
signal monologue_play_voice(path: String, player: AudioStreamPlayer2D)
signal monologue_update_background(path: String, background: Texture2D)
signal monologue_custom_action(raw_action: Dictionary)
signal monologue_timer_started(wait_time: float)
signal monologue_notify(level: NotificationLevel, message: String)

enum NotificationLevel {INFO, DEBUG, WARN, ERROR, CRITICAL}

var active_voiceline: AudioStreamPlayer2D
var active_timer: Timer
var base_path: String
var root_node_id: String
var node_list: Array
var characters: Array
var variables: Array
var events: Array
var next_id: Variant
var fallback_id: Variant


func _init():
	print("[INFO] Monologue Process initiated")


func load_dialogue(json_path: String, custom_id: Variant = null) -> void:
	var file = FileAccess.open(json_path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	base_path = file.get_path().get_base_dir()
	root_node_id = data.get("RootNodeID")
	node_list = data.get("ListNodes")
	characters = data.get("Characters")
	add_variables(data.get("Variables"))
	events = node_list.filter(func(n): return n.get("$type") == "NodeEvent")
	next_id = root_node_id if (custom_id is not String) else custom_id
	print("[INFO] Dialogue %s loaded" % json_path.get_file())


func next() -> void:
	skip_timer()
	skip_voiceline()
	parse_events()
	
	if next_id is not String:
		fallback()
	var node = find_node_from_id(next_id)
	if node:
		monologue_node_reached.emit(node)
		process_node(node)


func parse_events() -> void:
	for event in events:
		var condition = event.get("Condition")
		var variable = get_variable(condition.get("Variable"))
		if not variable:
			continue
		var v_value = variable.get("Value")
		var c_value = condition.get("Value")
		var condition_pass: bool
		match condition.get("Operator"):
			"==": condition_pass = v_value == c_value
			">=": condition_pass = v_value >= c_value
			"<=": condition_pass = v_value <= c_value
			"!=": condition_pass = v_value != c_value
		if condition_pass:
			monologue_event_triggered.emit(event)
			fallback_id = next_id
			next_id = event.get("NextID")
			events.erase(event)


func fallback() -> void:
	if fallback_id:
		next_id = fallback_id
		fallback_id = null
	else:
		monologue_end.emit(null)


func find_node_from_id(node_id: Variant) -> Dictionary:
	if node_id is String:
		for node in node_list:
			if node.get("ID") == node_id:
				return node
	return {}


func process_node(node: Dictionary) -> void:
	match node.get("$type"):
		"NodeRoot", "NodeBridgeIn", "NodeBridgeOut":
			next_id = node.get("NextID")
			next()
		
		"NodeSentence":
			next_id = node.get("NextID")
			var sentence = process_conditional_text(node.get("Sentence"))
			var speaker_name = get_speaker_name(node.get("SpeakerID"))
			var display_name = node.get("DisplaySpeakerName")
			if not display_name:
				display_name = speaker_name
			
			var path = node.get("VoicelinePath", "")
			if path:
				if path.is_relative_path():
					path = base_path + "/" + path
				active_voiceline = play_audio(path)
				if active_voiceline:
					monologue_play_voice.emit(path, active_voiceline)
			monologue_sentence.emit(sentence, display_name, speaker_name)
		
		"NodeChoice":
			var options: Array = []
			for option_id in node.get("OptionsID"):
				var option = find_node_from_id(option_id)
				if not option:
					monologue_notify.emit(NotificationLevel.WARN,
							"Can't find option with id: %s" % option_id)
					continue
				if option.get("Enable") == false:
					continue
				options.append(option)
			monologue_new_choice.emit(options)
		
		"NodeDiceRoll":
			if roll_dice() <= node.get("Target"):
				next_id = node.get("PassID")
			else:
				next_id = node.get("FailID")
			next()
		
		"NodeAction":
			next_id = node.get("NextID")
			process_action(node.get("Action"))
		
		"NodeCondition":
			var condition = node.get("Condition")
			var variable = get_variable(condition.get("Variable"))
			if variable:
				var if_nid = node.get("IfNextID")
				var else_nid = node.get("ElseNextID")
				var v_val = variable.get("Value")
				var c_val = condition.get("Value")
				next_id = if_nid
				match condition.get("Operator"):
					"==": next_id = if_nid if v_val == c_val else else_nid
					">=": next_id = if_nid if v_val >= c_val else else_nid
					"<=": next_id = if_nid if v_val <= c_val else else_nid
					"!=": next_id = if_nid if v_val != c_val else else_nid
			else:
				var var_name = variable.get("Name")
				var warning = "Can't find variable %s. Skipping." % var_name
				monologue_notify.emit(NotificationLevel.WARN, warning)
			next()
		
		"NodeEndPath":
			monologue_end.emit(node)
			next_story(node.get("NextStoryName"))


func process_action(raw_action: Dictionary) -> void:
	match raw_action.get("$type"):
		"ActionOption":
			var option_id = raw_action.get("OptionID")
			var value = raw_action.get("Value")
			set_option_value(option_id, value if value is bool else false)
		
		"ActionVariable":
			var variable = get_variable(raw_action.get("Variable"))
			if variable:
				var action_value = raw_action.get("Value")
				match raw_action.get("Operator"):
					"=": variable["Value"] = action_value
					"+": variable["Value"] += action_value
					"-": variable["Value"] -= action_value
					"*": variable["Value"] *= action_value
					"/":
						if action_value != 0:
							variable["Value"] /= action_value
						else:
							monologue_notify.emit(NotificationLevel.WARN,
								"Can't divide %s by 0." % variable.get("Name"))
			else:
				var warning = "Can't find variable. Skipping."
				monologue_notify.emit(NotificationLevel.WARN, warning)
		
		"ActionCustom":
			match raw_action.get("CustomType"):
				"PlayAudio":
					var path = raw_action.get("Value")
					if path.is_relative_path():
						path = base_path + "/" + path
						if not FileAccess.file_exists(path):
							var backup = "/assets/audios/"
							path = base_path + backup + path.get_file()
					
					var volume = raw_action.get("Volume")
					var pitch = raw_action.get("Pitch")
					var loop = raw_action.get("Loop")
					var track = play_audio(path, loop, volume, pitch)
					if track:
						monologue_play_audio.emit(path, track)
				
				"UpdateBackground":
					var bg = Image.new()
					var path = raw_action.get("Value")
					if path.is_relative_path():
						path = base_path + "/" + path
						if not FileAccess.file_exists(path):
							var backup = "/assets/backgrounds/"
							path = base_path + backup + path.get_file()

					if FileAccess.file_exists(path):
						var status = bg.load(path)
						if status == OK:
							var texture = ImageTexture.create_from_image(bg)
							monologue_update_background.emit(path, texture)
						else:
							monologue_notify.emit(NotificationLevel.WARN,
									"Failed to load background (%s)" % path)
				
				"Other":
					monologue_custom_action.emit(raw_action)
		
		"ActionTimer":
			start_timer(raw_action.get("Value", 0.0))
			return  # return so next() is not called immediately
	next()


func process_conditional_text(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("(?<=\\{{)(.*?)(?=\\}})")
	var results = regex.search_all(text)
	for result in results:
		var target = result.get_string()
		var replacement = str(evaluate_expression(substitute_variables(target)))
		if target != replacement:
			text = text.replace("{{" + target + "}}", replacement)
	return text


func evaluate_expression(expression: String) -> Variant:
	if expression.contains("if"):
		# split into two parts from "then" clause
		var t_split = expression.split("then", false, 1)
		if t_split.size() > 1:
			# the first element is the "if <<variable>>" clause
			var check = t_split[0].strip_edges().trim_prefix("if").lstrip(" ")
			
			# evaluate condition check to has_passed
			var has_passed = false
			var checker = Expression.new()
			if checker.parse(check) == OK:
				var conditional = checker.execute([], checker, false)
				if not checker.has_execute_failed() and conditional:
					has_passed = bool(conditional)
			
			# select then or else clause depending on has_passed
			var e_split = t_split[1].rsplit("else", false, 1)
			if has_passed:
				var then_value = e_split[0].strip_edges().trim_prefix("then")
				return evaluate_expression(then_value.lstrip(" "))
			else:
				var else_value = e_split[1] if e_split.size() > 1 else ""
				return evaluate_expression(else_value.strip_edges())
	
	var parser = Expression.new()
	var result = null
	if expression:
		parser.parse(expression)
		result = parser.execute([], parser, false)
	return expression if parser.has_execute_failed() or not result else result


func substitute_variables(expression: String) -> String:
	var subber = RegEx.new()
	subber.compile("['\"]?[a-zA-Z][\\w]*['\"]?")
	var results = subber.search_all(expression)
	var start = 0
	var builder = ""
	
	for result in results:
		var text = result.get_string()
		if text.contains("\"") or text.contains("'"):
			continue
		
		var variable = get_variable(text)
		if variable:
			var value = str(variable.get("Value"))
			# encase value in quotes if type is String
			if variable.get("Type") == "String":
				value = "\"" + value + "\""
			builder += expression.substr(start, result.get_start() - start)
			builder += value
			start = result.get_end()
	
	builder += expression.substr(start, expression.length() - start)
	return builder


func get_speaker_name(speaker_id) -> String:
	for speaker in characters:
		if speaker.get("ID") == speaker_id:
			return speaker.get("Reference")
	return ""


func get_variable(variable_name: String) -> Dictionary:
	for variable in variables:
		if variable.get("Name") == variable_name:
			return variable
	return {}


func add_variables(new_variables: Array) -> void:
	for data in new_variables:
		var exists = get_variable(data.get("Name"))
		if not exists:
			variables.append(data)


func roll_dice(minimum: int = 0, maximum: int = 100) -> int:
	var dice = RandomNumberGenerator.new()
	dice.randomize()
	return dice.randi_range(minimum, maximum)


func start_timer(wait_time: float) -> void:
	if not active_timer or not is_instance_valid(active_timer):
		active_timer = Timer.new()
		active_timer.one_shot = true
		active_timer.connect("timeout", next)
		add_child(active_timer)
	active_timer.start(wait_time)
	monologue_timer_started.emit(wait_time)


func skip_timer() -> void:
	if active_timer and is_instance_valid(active_timer):
		active_timer.stop()


func play_audio(path: String, loop: bool = false, volume: float = 0.0,
			pitch: float = 1.0) -> AudioStreamPlayer2D:
	match SfxLoader.load_track(path, loop, volume, pitch):
		ERR_FILE_NOT_FOUND:
			var message = "Audio file %s not found!" % path.get_file()
			monologue_notify.emit(NotificationLevel.ERROR, message)
		
		ERR_INVALID_PARAMETER:
			var message = "Audio file extension not supported!"
			monologue_notify.emit(NotificationLevel.ERROR, message)
		
		ERR_PARSE_ERROR:
			var message = "Failed to parse audio %s!" % path.get_file()
			if path.get_extension() == "wav":
				message += " Only 8-bit and 16-bit WAV is supported."
			monologue_notify.emit(NotificationLevel.ERROR, message)
		
		OK:
			return SfxLoader.get_track()
	return null


func skip_voiceline() -> void:
	if active_voiceline and is_instance_valid(active_voiceline):
		active_voiceline.queue_free()  # stop voiceline if still playing
	active_voiceline = null


func set_option_value(option_id: String, value: bool) -> void:
	var option = find_node_from_id(option_id)
	if option:
		option["Enable"] = value
	else:
		var warning = "Can't find option. Skipping."
		monologue_notify.emit(NotificationLevel.WARN, warning)


func select_option(raw_option: Dictionary) -> void:
	monologue_option_chosen.emit(raw_option)
	
	if raw_option.keys().has("OneShot") and raw_option.keys().has("Enable"):
		next_id = raw_option.get("NextID", -1)
		if raw_option.get("OneShot") == true:
			raw_option["Enable"] = false
		next()
	else:
		var error_message = "Invalid option. Unexpected exit."
		monologue_notify.emit(NotificationLevel.CRITICAL, error_message)
		monologue_end.emit(null)


func next_story(story_name: String) -> void:
	if story_name:
		var trimmed = story_name.trim_suffix(".json")
		if trimmed.is_relative_path():
			trimmed = base_path + "/" + trimmed
		if FileAccess.file_exists(trimmed + ".json"):
			load_dialogue(trimmed + ".json")
			next()
