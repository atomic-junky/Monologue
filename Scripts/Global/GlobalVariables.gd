extends Node


## Dictionary of Monologue node types and their corresponding scenes.
var node_dictionary = {
	"Root": preload("res://Objects/GraphNodes/RootNode.tscn"),
	"Audio": preload("res://Objects/GraphNodes/AudioNode.tscn"),
	"Action": preload("res://Objects/GraphNodes/ActionNode.tscn"),
	"Background": preload("res://Objects/GraphNodes/BackgroundNode.tscn"),
	"Bridge": preload("res://Objects/GraphNodes/BridgeInNode.tscn"),
	"BridgeIn": preload("res://Objects/GraphNodes/BridgeInNode.tscn"),
	"BridgeOut": preload("res://Objects/GraphNodes/BridgeOutNode.tscn"),
	"Choice": preload("res://Objects/GraphNodes/ChoiceNode.tscn"),
	"Comment": preload("res://Objects/GraphNodes/CommentNode.tscn"),
	"Condition": preload("res://Objects/GraphNodes/ConditionNode.tscn"),
	"Random": preload("res://Objects/GraphNodes/RandomNode.tscn"),
	"EndPath": preload("res://Objects/GraphNodes/EndPathNode.tscn"),
	"Event": preload("res://Objects/GraphNodes/EventNode.tscn"),
	"Sentence": preload("res://Objects/GraphNodes/SentenceNode.tscn"),
	"Setter": preload("res://Objects/GraphNodes/SetterNode.tscn"),
	"Wait": preload("res://Objects/GraphNodes/WaitNode.tscn"),
	"Reroute": preload("res://Objects/GraphNodes/RerouteNode.tscn")
}

var empty_callback: Callable = func(): return
var test_path: String
