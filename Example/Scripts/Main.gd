extends Control


@onready var menu_scene = preload("res://Example/Menu.tscn").instantiate()

@onready var text_box = $CenterContainer/MarginContainer/Container/TextBox
@onready var choice_panel = $CenterContainer/MarginContainer/Container/ChoicePanel

@onready var character_asset_node = $CharacterAssetContainer/Asset

var Process


func _ready():
	Process = MonologueProcess.new(text_box, choice_panel, end_callback, character_asset_node, get_character_asset)
	Process.load_dialogue("intro")
	Process.next()

func _input(event):
	if event.is_action_pressed("ui_accept") and text_box.complete and not choice_panel.visible:
		Process.next()

func end_callback():
	get_tree().change_scene_to_file("res://Example/Menu.tscn")
	get_tree().unload_current_scene()

func get_character_asset(character):
	match character:
		"Lazy God":
			return preload("res://Example/Assets/lazyGod.png")
		"Douglas Adams":
			return preload("res://Example/Assets/douglasAdams.png")
	return
