extends Node


## Dictionary of Monologue node types and their corresponding scenes.
var node_dictionary = {
	"Root": preload("res://modules/root_node/root_node.tscn"),
	"Audio": preload("res://modules/audio_node/audio_node.tscn"),
	"Action": preload("res://modules/action_node/action_node.tscn"),
	"Background": preload("res://modules/background_node/background_node.tscn"),
	"Bridge": preload("res://modules/bridge_in_node/bridge_in_node.tscn"),
	"BridgeIn": preload("res://modules/bridge_in_node/bridge_in_node.tscn"),
	"BridgeOut": preload("res://modules/bridge_out_node/bridge_out_node.tscn"),
	"Choice": preload("res://modules/choice_node/choice_node.tscn"),
	"Comment": preload("res://modules/comment_node/comment_node.tscn"),
	"Condition": preload("res://modules/condition_node/condition_node.tscn"),
	"Random": preload("res://modules/random_node/random_node.tscn"),
	"EndPath": preload("res://modules/end_path_node/end_path_node.tscn"),
	"Event": preload("res://modules/event_node/event_node.tscn"),
	"Sentence": preload("res://modules/sentence_node/sentence_node.tscn"),
	"Setter": preload("res://modules/setter_node/setter_node.tscn"),
	"Wait": preload("res://modules/wait_node/wait_node.tscn"),
	"Reroute": preload("res://modules/reroute_node/reroute_node.tscn")
}

var empty_callback: Callable = func(): return
var test_path: String
