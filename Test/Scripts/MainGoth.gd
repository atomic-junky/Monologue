extends MonologueProcess


@onready var menu_scene = preload("res://Test/Menu.tscn").instantiate()
@onready var option = preload("res://Test/Objects/button.tscn")

@onready var option_container = $OptionContainer
@onready var character_container = $TextBoxContainer/Character/CharacterContainer
@onready var character_label = $TextBoxContainer/Character/CharacterContainer/Label
@onready var text_box = $TextBoxContainer/Text/RichTextLabel
@onready var choice_panel = $OptionContainer
@onready var background_node = $Background
@onready var audio_player = $AudioStreamPlayer

var is_completed: bool = true

func _ready():
	var global_vars = get_node("/root/GlobalVariables")	
	var path = global_vars.test_path
	
	load_dialogue(path.get_basename())
	next()

func _input(event):
	if event.is_action_pressed("ui_accept") and is_completed and not choice_panel.visible:
		next()

func get_character_asset(character, _variant = null):
	if character == "_NARRATOR":
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


func _on_end(raw_end):
	if not raw_end or not raw_end.get("NextStoryName"):
		var menu_instance = preload("res://Test/Menu.tscn")
		var menu_scene_instance = menu_instance.instantiate()
		
		get_tree().root.add_child(menu_scene_instance)
		queue_free()


func _on_sentence(text, speaker, speaker_name):
	is_completed = false
	text_box.text = text
	
	if not speaker.begins_with("_"):
		character_container.show()
		character_label.text = speaker_name
	else:
		character_container.hide()
	
	await _display_sentence()

func _display_sentence():
	for i in len(text_box.text):
		text_box.visible_characters = i
		await get_tree().create_timer(0.005).timeout
	text_box.visible_characters = -1
		
	is_completed = true


func _on_new_choice(options):
	choice_panel.hide()
	for child in choice_panel.get_children():
		child.queue_free()
		
	for opt in options:
		var new_opt = option.instantiate()
		new_opt.text = opt.get("Sentence")
		new_opt.connect("pressed", option_selected.bind(opt))
		option_container.add_child(new_opt)
	
	option_container.show()


func _on_option_choosed(_raw_option):
	for opt in choice_panel.get_children():
		opt.queue_free()


func character_resized():
	var lb_x = $TextBoxContainer/Character/CharacterContainer/Label.size.x
	$TextBoxContainer/Character/CharacterContainer/CharacterBox.size.x = lb_x + 12
