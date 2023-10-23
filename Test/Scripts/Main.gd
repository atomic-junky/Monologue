extends Control


@onready var menu_scene = preload("res://Test/Menu.tscn").instantiate()

@onready var text_box = $CenterContainer/MarginContainer/Container/TextBox
@onready var choice_panel = $CenterContainer/MarginContainer/Container/ChoicePanel

@onready var character_asset_node = $CharacterAssetContainer/Asset

var rng = RandomNumberGenerator.new()
var Process


func _ready():
	var global_vars = get_node("/root/GlobalVariables")
	var path = global_vars.test_path
	
	Process = MonologueProcess.new(text_box, choice_panel, end_callback, action_callback, character_asset_node, get_character_asset)
	Process.load_dialogue(path.get_basename())
	Process.next()

func _input(event):
	if event.is_action_pressed("ui_accept") and text_box.complete and not choice_panel.visible:
		Process.next()

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
