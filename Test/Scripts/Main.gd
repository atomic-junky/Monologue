extends MonologueProcess


@onready var menu_scene = preload("res://Test/Menu.tscn").instantiate()
@onready var text_box = preload("res://Test/Objects/text_box.tscn")
@onready var option_button = preload("res://Test/Objects/option_button.tscn")

@onready var text_box_container = $MarginContainer/MarginContainer/ScrollContainer/Container/TextBoxContainer
@onready var choice_container = $MarginContainer/MarginContainer/ScrollContainer/Container/ChoiceContainer
@onready var background_node = $Background
@onready var audio_player = $AudioStreamPlayer
@onready var character_container = $CharacterAssetContainer/Asset

var is_completed: bool = true

func _ready():
	var global_vars = get_node("/root/GlobalVariables")
	var path = global_vars.test_path
	
	load_dialogue(path.get_basename())
	next()

func _input(event):
	if event.is_action_pressed("ui_accept") and is_completed and not choice_container.visible:
		next()

func get_character_asset(character: String, _variant = null):
	if character.begins_with("_"):
		return
		
	rng.seed = hash(character)
	var rng_nbr = rng.randi_range(0, 5)
	match  rng_nbr:
		0:
			return
		1:
			return preload("res://Test/Assets/AlbertoMielgo01.png")
		2:
			return preload("res://Test/Assets/AlbertoMielgo02.png")
		3:
			return preload("res://Test/Assets/AlbertoMielgo03.png")
		4:
			return preload("res://Test/Assets/AlbertoMielgo04.png")
		5:
			return preload("res://Test/Assets/AlbertoMielgo05.png")
	
	return


func _on_monologue_end(raw_end):
	if not raw_end or not raw_end.get("NextStoryName"):
		var menu_instance = preload("res://Test/Menu.tscn")
		var menu_scene_instance = menu_instance.instantiate()
		
		get_tree().root.add_child(menu_scene_instance)
		SfxLoader.clear()
		queue_free()


func _on_monologue_sentence(sentence, speaker, speaker_name):
	# Textbox
	var new_textbox: RichTextLabel = text_box.instantiate()
	
	if speaker_name.begins_with("_"):
		new_textbox.text = sentence
		new_textbox.visible_characters = 0
	else:
		new_textbox.text = "[color=e75a41]" + speaker_name + "[/color]\n"
		new_textbox.text += sentence
		new_textbox.visible_characters = len(speaker_name)
	
	# Speaker
	var char_asset = get_character_asset(speaker, speaker_name)
	if char_asset:
		if not character_container.visible:
			character_container.position.x = -character_container.size.x
			character_container.show()
			character_container.texture = char_asset
			get_tree().create_tween().tween_property(character_container, "position:x", 50, 0.1)
	else:
		character_container.position.x = 50
		get_tree().create_tween().tween_property(character_container, "position:x", -character_container.size.x, 0.1)
		
		character_container.hide()
	
	for tb: RichTextLabel in text_box_container.get_children():
		tb.modulate = Color(1, 1, 1, 0.6)
	
	text_box_container.add_child(new_textbox)
	
	get_tree().create_tween().tween_property(new_textbox, "visible_characters", len(new_textbox.text), 0.5)


func _on_monologue_new_choice(options):
	for option in options:
		var new_option = option_button.instantiate()
		new_option.text = option.get("Sentence")
		new_option.connect("pressed", option_selected.bind(option))
		
		choice_container.add_child(new_option)
	
	choice_container.show()


func _on_monologue_option_choosed(_raw_option):
	choice_container.hide()
	for child in choice_container.get_children():
		child.queue_free()


func _on_monologue_event_triggered(raw_event):
	var event_id = raw_event.get("ID").split("-")[0]
	
	var condition = raw_event.get("Condition")
	var condition_display = str(condition.get("Variable")) + " " + str(condition.get("Operator")) + " " + str(condition.get("Value"))
	
	$Notification.debug("Event triggered [color=7f7f7f](" + event_id + ")[/color]\n" + "Condition: [color=7f7f7f]" + condition_display + "[/color]")


func _on_monologue_update_background(path, _texture):
	$Notification.debug("Update Background instruction received [color=7f7f7f](" + path + ")[/color]")


func _on_monologue_play_audio(path, _stream):
	$Notification.debug("Play Audio instruction received [color=7f7f7f](" + path + ")[/color]")


func _on_monologue_custom_action(raw_action):
	$Notification.debug("Custom action received [color=7f7f7f](" + raw_action.get("Value") + ")[/color]")
