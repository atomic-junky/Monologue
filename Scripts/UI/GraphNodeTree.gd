extends Tree


@onready var create_btn: Button = %CreateButton

## The data to build the tree
## An oject can contain keys with name "text", "value", icon" and "children".
var _data =  [
		{"text": "Main", "children": [
			{"text": "Sentence", "icon": "Placeholder"},
			{"text": "Choice"},
		]},
		{"text": "Logic", "children": [
			{"text": "Action", "icon": "Placeholder"},
			{"text": "Condition", "icon": "Placeholder"},
			{"text": "Event", "icon": "Placeholder"},
			{"text": "DiceRoll", "icon": "Placeholder"},
		]},
		{"text": "Audio", "children": [
			{"text": "Audio", "icon": "Placeholder"},
		]},
		{"text": "Helpers", "children": [
			{"text": "Comment", "icon": "Placeholder"},
		]}
	]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = create_item()
	_recusive_load_data(_data, root)
	deselect_all()

func _recusive_load_data(items: Array, tree_parent: TreeItem) -> void:
	for obj: Dictionary in items:
		var tree_item = create_item(tree_parent)
		tree_item.collapsed = true
		
		if obj.has("text"):
			tree_item.set_text(0, obj.get("text"))
		if obj.has("icon"):
			pass
		if obj.has("children"):
			_recusive_load_data(obj.get("children"), tree_item)


func _create() -> void:
	var node_type = get_selected().get_text(0)
	GlobalSignal.emit("add_graph_node", [node_type])


func _on_item_selected() -> void:
	var item: TreeItem = get_selected()
	create_btn.disabled = item.get_child_count() > 0
	
	
