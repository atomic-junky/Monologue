extends Node


## Dictionary of Monologue node types and their corresponding scenes.
var node_dictionary = {
	"Root": preload("res://Objects/GraphNodes/RootNode.tscn"),
	"Action": preload("res://Objects/GraphNodes/ActionNode.tscn"),
	"Bridge": preload("res://Objects/GraphNodes/BridgeInNode.tscn"),
	"BridgeIn": preload("res://Objects/GraphNodes/BridgeInNode.tscn"),
	"BridgeOut": preload("res://Objects/GraphNodes/BridgeOutNode.tscn"),
	"Choice": preload("res://Objects/GraphNodes/ChoiceNode.tscn"),
	"Comment": preload("res://Objects/GraphNodes/CommentNode.tscn"),
	"Condition": preload("res://Objects/GraphNodes/ConditionNode.tscn"),
	"DiceRoll": preload("res://Objects/GraphNodes/DiceRollNode.tscn"),
	"EndPath": preload("res://Objects/GraphNodes/EndPathNode.tscn"),
	"Event": preload("res://Objects/GraphNodes/EventNode.tscn"),
	"Sentence": preload("res://Objects/GraphNodes/SentenceNode.tscn"),
}

var empty_callback: Callable = func(): return
var test_path: String
