# Monologue 🦖

### About
Monologue is a powerful tool that allows you to create and edit dialogues in a node editor and then save them as a JSON file so you can use them anywhere.

You can find the wiki [here](https://github.com/atomic-junky/Monologue/wiki).


### Brief Steps to Start Your Story
1. Create or open a `.json` file.
2. Create your dialogues with the various nodes
3. Save the project for use in your story
4. Save the file and use it in your game


## Types of nodes
 - **Root Node**<br>
	The starting point of your story. There is only one Root Node in each file.

- **Sentence Node**<br>
	A node that represents a character's dialogue sentence.

- **Choice Node**<br>
	A node that allows the user to make choices and then select a specific branch. A Choice Node has several Option Nodes.

- **Option Node**<br>
	An option that can be chosen by the user in a Choice Node.

- **DiceRoll Node**<br>
	To have a bit of random stuff.

- **Action Node**<br>
	Update variables, choice node's options or just custom event.

- **Condition Node**<br>
	Check the value of a variable.

- **End Path Node**<br>
	This node represents the end of a path. It can be interpreted as an exit of the file.

- **Bridge Node**<br>
	- The Bridge node creates a connection between two nodes, when you create a Bridge node, two nodes appear, a BridgeInNode and a BridgeOutNode.
	- The `BridgeInNode` is the link's input node, and the `BridgeOutNode` is the link's exit node.
	- The modifiable number is the link number.


## The JSON file format
```json
{
	"EditorVersion": "",
	"RootNodeId": "", # The id of the root node (where all start)
	"ListNodes": [ # Where all the nodes are stored
		...
	],
	"Characters": [ # All the characters
		...
	],
	"Variables": [ # All the variables
		...
	]
}
```


## How it's interpreted
You can write your own script or use the **MonologueProcess** script [here](https://github.com/atomic-junky/Monologue/blob/main/Test/Scripts/MonologueProcess.gd).

To use the **MonologueProcess** script:
```swift
@onready var text_box = $.../TextBox
@onready var choice_panel = $.../ChoicePanel

@onready var character_asset_node = $.../Asset

var rng = RandomNumberGenerator.new()
var Process


func _ready():
	var path = "PATH_OF_THE_STORY_FILE"
	
	Process = MonologueProcess.new(text_box, choice_panel, end_callback, action_callback, character_asset_node, get_character_asset)
	Process.load_dialogue(path.get_basename())
	Process.next()


func _input(event):
	if event.is_action_pressed("ui_accept") and text_box.complete and not choice_panel.visible:
		Process.next()


func end_callback(next_story):
	pass


func action_callback(action):
	pass


func get_character_asset(character, variant = null):
	if character == "_NARRATOR":
		return
		
	match character:
		"character_01":
			match variant:
				"variant_01":
					return preload("res://character_01/variant_01.png")
				
				"variant_02":
					return preload("res://character_01/variant_02.png")
		"character_02":
			return preload("res://character_02.png")
		"character_03":
			return preload("res://character_03.png")
	
	return
```



## More Support
This project is originally from Amberlim, so if you want, here is her [Discord server](https://discord.gg/AAcKmJz7Na). However, if you need help, don't hesitate to create an issue on Github.
