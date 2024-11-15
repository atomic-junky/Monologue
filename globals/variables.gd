extends Node


## Dictionary of Monologue node types and their corresponding scenes.
var node_dictionary = {
	"Root": preload("res://scenes/prefabs/graph_nodes/root_node/root_node.tscn"),
	"Audio": preload("res://scenes/prefabs/graph_nodes/audio_node/audio_node.tscn"),
	"Action": preload("res://scenes/prefabs/graph_nodes/action_node/action_node.tscn"),
	"Background": preload("res://scenes/prefabs/graph_nodes/background_node/background_node.tscn"),
	"Bridge": preload("res://scenes/prefabs/graph_nodes/bridge_in_node/bridge_in_node.tscn"),
	"BridgeIn": preload("res://scenes/prefabs/graph_nodes/bridge_in_node/bridge_in_node.tscn"),
	"BridgeOut": preload("res://scenes/prefabs/graph_nodes/bridge_out_node/bridge_out_node.tscn"),
	"Choice": preload("res://scenes/prefabs/graph_nodes/choice_node/choice_node.tscn"),
	"Comment": preload("res://scenes/prefabs/graph_nodes/comment_node/comment_node.tscn"),
	"Condition": preload("res://scenes/prefabs/graph_nodes/condition_node/condition_node.tscn"),
	"Random": preload("res://scenes/prefabs/graph_nodes/random_node/random_node.tscn"),
	"EndPath": preload("res://scenes/prefabs/graph_nodes/end_path_node/end_path_node.tscn"),
	"Event": preload("res://scenes/prefabs/graph_nodes/event_node/event_node.tscn"),
	"Sentence": preload("res://scenes/prefabs/graph_nodes/sentence_node/sentence_node.tscn"),
	"Setter": preload("res://scenes/prefabs/graph_nodes/setter_node/setter_node.tscn"),
	"Wait": preload("res://scenes/prefabs/graph_nodes/wait_node/wait_node.tscn"),
	"Reroute": preload("res://scenes/prefabs/graph_nodes/reroute_node/reroute_node.tscn")
}

var empty_callback: Callable = func(): return
var test_path: String
