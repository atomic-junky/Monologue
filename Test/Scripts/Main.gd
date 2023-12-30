extends MonologueProcess


@onready var menu_scene = preload("res://Test/Menu.tscn").instantiate()

@onready var option_container = $MarginContainer/MarginContainer/ScrollContainer/Container/ChoicePanel
@onready var text_box = $MarginContainer/MarginContainer/ScrollContainer/Container/TextBoxContainer
@onready var choice_panel = $MarginContainer/MarginContainer/ScrollContainer/Container/ChoicePanel
@onready var background_node = $Background
@onready var audio_player = $AudioStreamPlayer
@onready var character_asset_node = $CharacterAssetContainer/Asset

var is_completed: bool = true

func _ready():
	var global_vars = get_node("/root/GlobalVariables")
	var path = global_vars.test_path
	
	load_dialogue(path.get_basename())
	next()

func _input(event):
	if event.is_action_pressed("ui_accept") and text_box.complete and not choice_panel.visible:
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

