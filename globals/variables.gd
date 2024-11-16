extends Node


## Dictionary of Monologue node types and their corresponding scenes.
var node_dictionary = {
	"Root": preload("res://graph_nodes/root_node/root_node.tscn"),
	"Audio": preload("res://graph_nodes/audio_node/audio_node.tscn"),
	"Action": preload("res://graph_nodes/action_node/action_node.tscn"),
	"Background": preload("res://graph_nodes/background_node/background_node.tscn"),
	"Bridge": preload("res://graph_nodes/bridge_in_node/bridge_in_node.tscn"),
	"BridgeIn": preload("res://graph_nodes/bridge_in_node/bridge_in_node.tscn"),
	"BridgeOut": preload("res://graph_nodes/bridge_out_node/bridge_out_node.tscn"),
	"Choice": preload("res://graph_nodes/choice_node/choice_node.tscn"),
	"Comment": preload("res://graph_nodes/comment_node/comment_node.tscn"),
	"Condition": preload("res://graph_nodes/condition_node/condition_node.tscn"),
	"Random": preload("res://graph_nodes/random_node/random_node.tscn"),
	"EndPath": preload("res://graph_nodes/end_path_node/end_path_node.tscn"),
	"Event": preload("res://graph_nodes/event_node/event_node.tscn"),
	"Sentence": preload("res://graph_nodes/sentence_node/sentence_node.tscn"),
	"Setter": preload("res://graph_nodes/setter_node/setter_node.tscn"),
	"Wait": preload("res://graph_nodes/wait_node/wait_node.tscn"),
	"Reroute": preload("res://graph_nodes/reroute_node/reroute_node.tscn")
}

var empty_callback: Callable = func(): return
var test_path: String
