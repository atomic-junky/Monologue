extends Control


@onready var menu_scene = preload("res://Test/Menu.tscn").instantiate()

@onready var text_box = $CenterContainer/MarginContainer/Container/TextBox
@onready var choice_panel = $CenterContainer/MarginContainer/Container/ChoicePanel

@onready var character_asset_node = $CharacterAssetContainer/Asset

var Process


func _ready():
	var global_vars = get_node("/root/GlobalVariables")
	var path = global_vars.test_path
	
	Process = MonologueProcess.new(text_box, choice_panel, end_callback, character_asset_node, get_character_asset)
	Process.load_dialogue(path.get_basename())
	Process.next()

func _input(event):
	if event.is_action_pressed("ui_accept") and text_box.complete and not choice_panel.visible:
		Process.next()

func end_callback():
	var menu_instance = preload("res://Test/Menu.tscn")
	var menu_scene = menu_instance.instantiate()
	
	get_tree().root.add_child(menu_scene)
	queue_free()

func get_character_asset(character):
	match character:
		"Lazy God":
			return preload("res://Test/Assets/lazyGod.png")
		"Douglas Adams":
			return preload("res://Test/Assets/douglasAdams.png")
	return
