extends MonologueProcess


@onready var menu_scene = preload("res://Test/Menu.tscn").instantiate()

func _ready():
	var global_vars = get_node("/root/GlobalVariables")
	
	text_box = $MarginContainer/MarginContainer/ScrollContainer/Container/TextBoxContainer
	choice_panel = $MarginContainer/MarginContainer/ScrollContainer/Container/ChoicePanel
	background_node = $Background
	audio_player = $AudioStreamPlayer
	character_asset_node = $CharacterAssetContainer/Asset
	
	var path = global_vars.test_path
	
	load_dialogue(path.get_basename())
	next()

func _input(event):
	if event.is_action_pressed("ui_accept") and text_box.complete and not choice_panel.visible:
		next()

func end_callback(_next_story = null):
	var menu_instance = preload("res://Test/Menu.tscn")
	var menu_scene_instance = menu_instance.instantiate()
	
	get_tree().root.add_child(menu_scene_instance)
	queue_free()

func action_callback(_action):
	print("[INFO] Can't process custom action. Skipping")
	pass

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
