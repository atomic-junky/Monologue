extends MonologueProcess


@onready var text_box = preload("res://scenes/run/objects/text_box.tscn")
@onready var option_button = preload("res://scenes/run/objects/option_button.tscn")

# SidePanel nodes
@onready var sp_text_box_container = $SidePanelContainer/PanelContainer/MarginContainer/ScrollContainer/Container/ScrollContainer/TextBoxContainer
@onready var sp_choice_container = $SidePanelContainer/PanelContainer/MarginContainer/ScrollContainer/Container/ChoiceContainer
@onready var sp_scroll_container: ScrollContainer = $SidePanelContainer/PanelContainer/MarginContainer/ScrollContainer/Container/ScrollContainer
@onready var sp_scrollbar: ScrollBar = sp_scroll_container.get_v_scroll_bar()
# TextBox nodes
@onready var tb_text_label = $TextBoxContainer/PanelContainer/MarginContainer/Container/TextLabel
@onready var tb_choice_container = $TextBoxContainer/PanelContainer/MarginContainer/Container/ChoiceContainer

@onready var background_node = $Background
@onready var character_container = $CharacterAssetContainer/Asset
@onready var notification = $NotificationContainer/CenterContainer/Notification

var from_node: Variant
var file_path: String

var is_completed: bool = true
var is_notification_skippable: bool


func _ready():
	sp_scrollbar.connect("changed", _handle_scrollbar_changed)
	
	if file_path:
		from_node = null if from_node == "-1" else from_node
		if from_node:
			_on_monologue_sentence("Skipped to the node " + from_node + "!", "_DEBUG", "_DEBUG", true)
		load_dialogue(file_path, from_node)
		next()


func _input(event):
	if event.is_action_pressed("ui_accept") and is_completed and not sp_choice_container.visible:
		if is_notification_skippable:
			notification.hide()
			is_notification_skippable = false
		next()


func _handle_scrollbar_changed():
	sp_scroll_container.scroll_vertical = int(sp_scrollbar.max_value)


func get_character_asset(character: String, _variant = null):
	if character.begins_with("_"):
		return
	
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(character)
	var rng_nbr = rng.randi_range(0, 5)
	match rng_nbr:
		0:
			return
		1:
			return preload("res://scenes/run/assets/AlbertoMielgo01.png")
		2:
			return preload("res://scenes/run/assets/AlbertoMielgo02.png")
		3:
			return preload("res://scenes/run/assets/AlbertoMielgo03.png")
		4:
			return preload("res://scenes/run/assets/AlbertoMielgo04.png")
		5:
			return preload("res://scenes/run/assets/AlbertoMielgo05.png")
	
	return


func _on_monologue_end(raw_end):
	if not raw_end or not raw_end.get("NextStory", raw_end.get("NextStoryName")):
		_exit()


func _exit():
	var menu_instance = load("res://scenes/run/menu/menu.tscn")
	var menu_scene_instance = menu_instance.instantiate()
	menu_scene_instance.from_node = from_node
	menu_scene_instance.file_path = file_path
	get_window().add_child(menu_scene_instance)
	
	SfxLoader.clear()
	queue_free()


func _on_monologue_sentence(sentence, speaker, speaker_name, instant: bool = false):
	# Textbox
	var new_textbox: RichTextLabel = text_box.instantiate()
	tb_text_label.text = ""
	
	if speaker_name.begins_with("_"):
		new_textbox.text = sentence
		new_textbox.visible_characters = 0
		
		tb_text_label.text = sentence
		tb_text_label.visible_characters = 0
	else:
		new_textbox.text = "[color=e75a41]" + speaker_name + "[/color]\n"
		new_textbox.text += sentence
		new_textbox.visible_characters = len(speaker_name)
		
		tb_text_label.text = "[color=e75a41]" + speaker_name + "[/color]\n"
		tb_text_label.text += sentence
		tb_text_label.visible_characters = len(speaker_name)
	
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
	
	for tb: RichTextLabel in sp_text_box_container.get_children():
		tb.modulate = Color(1, 1, 1, 0.6)
	
	sp_text_box_container.add_child(new_textbox)
	
	if instant:
		new_textbox.visible_characters = len(new_textbox.text)
		tb_text_label.visible_characters = len(tb_text_label.text)
		return
	
	get_tree().create_tween().tween_property(new_textbox, "visible_characters", len(new_textbox.text), 0.5)
	get_tree().create_tween().tween_property(tb_text_label, "visible_characters", len(tb_text_label.text), 0.5)


func _instantiate_option(option):
	var new_option = option_button.instantiate()
	new_option.text = option.get("Option")
	new_option.connect("pressed", select_option.bind(option))
	return new_option


func _on_monologue_new_choice(options):
	for option in options:
		tb_choice_container.add_child(_instantiate_option(option))
		sp_choice_container.add_child(_instantiate_option(option))
	
	tb_choice_container.show()
	sp_choice_container.show()


func _on_monologue_option_chosen(_raw_option):
	tb_choice_container.hide()
	sp_choice_container.hide()
	
	var childs = sp_choice_container.get_children()
	childs.append_array(tb_choice_container.get_children())
	for child in childs:
		child.queue_free()


func _on_monologue_event_triggered(raw_event):
	var event_id = raw_event.get("ID").split("-")[0]
	
	var variable = str(raw_event.get("Variable"))
	var operator = str(raw_event.get("Operator"))
	var value = str(raw_event.get("Value"))
	
	var message = "Event triggered [color=7f7f7f](%s)[/color]\n" + \
			"Condition: [color=7f7f7f]%s %s %s[/color]"
	notification.debug(message % [event_id, variable, operator, value])


func _on_monologue_update_background(path, texture):
	if texture:
		background_node.texture = texture
	else:
		notification.debug("Update Background instruction received [color=7f7f7f](%s)[/color]" % path)


func _on_monologue_play_audio(path, _player):
	notification.debug("Play Audio instruction received [color=7f7f7f](%s)[/color]" % path.get_file())


func _on_monologue_custom_action(raw_action):
	var action_name = raw_action.get("Value", raw_action.get("Action"))
	if not action_name:
		action_name = "<<unnamed>>"
	notification.debug("Custom action received [color=7f7f7f](%s)[/color]" % action_name)


func _on_monologue_timer_started(wait_time):
	is_notification_skippable = true
	notification.info("Timer started for %d seconds" % wait_time, wait_time)


func _switch_mode_pressed(sp: bool = false):
	$SidePanelContainer.visible = not sp
	$TextBoxContainer.visible = sp


func _on_monologue_notify(level: NotificationLevel, text: String):
	match level:
		NotificationLevel.INFO:
			notification.info(text)
		NotificationLevel.DEBUG:
			notification.debug(text)
		NotificationLevel.WARN:
			notification.warn(text)
		NotificationLevel.ERROR:
			notification.error(text)
		NotificationLevel.CRITICAL:
			notification.critical(text)
