extends MenuButton


@onready var search_icon := preload("res://Assets/Icons/search.svg")


func _ready() -> void:
	var popup = get_popup()
	
	# Search item
	popup.add_icon_item(search_icon, "Search...")
	popup.set_item_shortcut(0, create_shortcut("Show searchbar"))
	
	popup.add_separator()
	
	# File item
	var file_submenu: PopupMenu = PopupMenu.new()
	file_submenu.add_item("New file")
	file_submenu.add_item("Open file")
	file_submenu.add_separator()
	file_submenu.add_item("Save file")
	file_submenu.add_item("Save file as")
	
	file_submenu.set_item_shortcut(3, create_shortcut("Save"))
	
	popup.add_submenu_node_item("File", file_submenu)
	
	# Edit item
	var edit_submenu: PopupMenu = PopupMenu.new()
	edit_submenu.add_item("Undo")
	edit_submenu.add_item("Redo")
	edit_submenu.add_separator()
	edit_submenu.add_item("Add node")
	
	edit_submenu.set_item_shortcut(0, create_shortcut("Undo"))
	edit_submenu.set_item_shortcut(1, create_shortcut("Redo"))
	
	popup.add_submenu_node_item("Edit", edit_submenu)
	
	# View item
	var view_submenu: PopupMenu = PopupMenu.new()
	view_submenu.add_check_item("Pixel grid")
	view_submenu.add_check_item("Snap to grid")
	view_submenu.add_separator()
	view_submenu.add_item("Zoom in")
	view_submenu.add_item("Zoom out")
	view_submenu.add_item("Zoom to 100%")
	view_submenu.add_item("Zoom to fit")
	view_submenu.add_item("Zoom to selection")
	
	popup.add_submenu_node_item("View", view_submenu)
	
	# Node item


func create_shortcut(action_name: StringName) -> Shortcut:
	var shortcut := Shortcut.new()
	
	var inputevent := InputEventAction.new()
	inputevent.action = action_name
	shortcut.events.append(inputevent)
	
	return shortcut
