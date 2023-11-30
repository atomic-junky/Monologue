extends Node

class_name MonologueProcess


var dir_path

var end_callback: Callable
var action_callback: Callable
var character_asset_getter: Callable

var text_box
var choice_panel
var character_asset_node
var prev_char_asset
var background_node
var audio_player: AudioStreamPlayer

var root_node_id: String
var node_list: Array
var characters: Array
var variables: Array
var events: Array

var next_id
var fallback_id

var rng = RandomNumberGenerator.new()


func _init(_text_box, _choice_panel, _background_node, _audio_player: AudioStreamPlayer, _end_callback: Callable, _action_callback: Callable, _character_asset_node = null, _character_asset_getter: Callable = _default_character_asset_getter):
	text_box = _text_box
	choice_panel = _choice_panel
	character_asset_node = _character_asset_node
	background_node = _background_node
	audio_player = _audio_player
	
	end_callback = _end_callback
	action_callback = _action_callback
	character_asset_getter = _character_asset_getter
	
	print("[INFO] Monologue Process initiated")


func load_dialogue(dialogue_name):
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
	variables = data.get("Variables")
	events = node_list.filter(func(n): return n.get("$type") == "NodeEvent")
	
	next_id = root_node_id
	
	print("[INFO] Dialogue " + path + " loaded")


func next():
	# Check for an event
	for event in events:
		var condition = event.get("Condition")
		var variable = get_variable(condition.get("Variable"))
		
		var v_val = variable.get("Value")
		var c_val = condition.get("Value")
		
		if variable == null:
			print("[WARNING] Can't find variable. Skipping")
			next()
			return
			
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
			fallback_id = next_id
			next_id = event.get("NextID")
			
			events.erase(event)
	
	if next_id is float and next_id == -1:
		if fallback_id:
			next_id = fallback_id
			fallback_id = null
		
		elif end_callback != null:
			return end_callback.call()
	
	var node = find_node_from_id(next_id)
	
	choice_panel.hide()
	choice_panel.clear()
	
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
			
			text_box.text = process_conditional_text(node.get("Sentence"))
			
			if character_asset_node:
				var texture = character_asset_getter.call(get_speaker(node.get("SpeakerID")))
				
				if prev_char_asset == null or prev_char_asset != texture:
					character_asset_node.undisplay()
					
					if texture != null:
						prev_char_asset = texture
						character_asset_node.set_texture(texture)
						character_asset_node.show()
						character_asset_node.display()
					else:
						character_asset_node.hide()
						prev_char_asset = null
			
			var display_speaker_name = node.get("DisplaySpeakerName")
			text_box.speaker_display = display_speaker_name if display_speaker_name else get_speaker(node.get("SpeakerID"))
			text_box.reset()
			text_box.update()
			text_box.display()
		"NodeChoice":
			choice_panel.clear()
			for option_id in node.get("OptionsID"):
				var option = find_node_from_id(option_id)
				if not option:
					print("[WARNING] Can't find option with id: " + option_id)
					continue
				if option.get("Enable") == false:
					continue
				
				choice_panel.add_button(option.get("Sentence"), option_callback.bind(option_id))
			choice_panel.show()
		"NodeDiceRoll":
			var roll = rng.randi_range(0, 100)
			if roll <= node.get("Target"):
				next_id = node.get("PassID")
			else:
				next_id = node.get("FailID")
		
			next()
			return
		"NodeAction":
			next_id = node.get("NextID")
			
			var action = node.get("Action")
			match action.get("$type"):
				"ActionOption":
					var option: Dictionary = find_node_from_id(action.get("OptionID"))
					
					if option == null:
						print("[WARNING] Can't find option. Skipping")
						next()
						return
					
					option["Enable"] = action.get("Value")
				"ActionVariable":
					var variable = get_variable(action.get("Variable"))
					
					if variable == null:
						print("[WARNING] Can't find variable. Skipping")
						next()
						return
					
					match action.get("Operator"):
						"=":
							variable["Value"] = action.get("Value")
						"+":
							variable["Value"] += action.get("Value")
						"-":
							variable["Value"] -= action.get("Value")
						"*":
							variable["Value"] *= action.get("Value")
						"/":
							if action.get("Value") != 0:
								variable["Value"] /= action.get("Value")
							else:
								print("[WARNING] Can't divide by value 0")
				"ActionCustom":
					match action.get("CustomType"):
						"PlayAudio":
							var file = FileAccess.open(dir_path + "\\assets\\audios\\" + action.get("Value"), FileAccess.READ)
							var sound = AudioStream.new()
							sound.data = file.get_buffer(file.get_length())
							
							audio_player.stream = sound
							audio_player.play()
						"UpdateBackground":
							var bg = Image.new()
							var err = bg.load(dir_path + "\\assets\\backgrounds\\" + action.get("Value"))
							
							if err != OK:
								print("[ERROR] Failed to load background (" + action.get("Value") + ")")
							
							var texture = ImageTexture.create_from_image(bg)
							background_node.set_texture(texture)
						"Other":
							action_callback.call(action.get("Value"))
			
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
				print("[WARNING] Can't find variable. Skipping")
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
			if end_callback != null:
				return end_callback.call(node.get("NextStoryName"))


func option_callback(option_id):
	var option: Dictionary = find_node_from_id(option_id)
	
	if option == null:
		print("[CRITICAL] Can't find option. Unexpected exit.")
		return end_callback.call()
	
	next_id = option.get("NextID")
	
	if option.get("OneShot") == true:
		option["Enable"] = false
	
	next()


func find_node_from_id(id):
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
			print("[ERROR] Can't find the variable " + var_name)
		
		if variable.get("Type") != "Boolean":
			print("[ERROR] The variable can only be of type Boolean (not " + variable.get("Type")  + ")")
			return text
		
		if variable.get("Value") == true:
			text = text.replace(original_condition, then_name)
			continue
		text = text.replace(original_condition, else_name)
		
	return text


func _default_character_asset_getter(_character):
	return
