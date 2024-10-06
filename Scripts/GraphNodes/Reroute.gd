class_name RerouteNode extends MonologueGraphNode


@onready var drag_panel: PanelContainer = $Control/CenterContainer/DragPanel


func _ready() -> void:
	drag_panel.modulate.a = 0
	node_type = "NodeReroute"
	super._ready()
	title = ""


func _on_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(drag_panel, "modulate:a", 1, 0.1)


func _on_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(drag_panel, "modulate:a", 0, 0.1)
