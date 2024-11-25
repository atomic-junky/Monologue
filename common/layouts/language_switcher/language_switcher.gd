extends Button


@onready var dropdown_container: Control = $DropdownContainer
@onready var vbox: VBoxContainer = $DropdownContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

@onready var language_option := preload("res://common/layouts/language_switcher/language_option.tscn")
@onready var arrow_left := preload("res://ui/assets/icons/arrow_left.svg")
@onready var arrow_down := preload("res://ui/assets/icons/arrow_down.svg")


func _ready() -> void:
	dropdown_container.hide()


func _on_pressed() -> void:
	dropdown_container.visible = !dropdown_container.visible
	
	if dropdown_container.visible:
		icon = arrow_down
	else:
		icon = arrow_left


func _on_btn_add_pressed() -> void:
	var new_option := language_option.instantiate()
	vbox.add_child(new_option)
