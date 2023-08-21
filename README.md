# Monologue 🦖
A fork of an untitled godot dialog system by Amberlim. (using Godot 4.x)

This system converts your story/dialog into a JSON file which you can then use to create your dialog in game.
The app this application allows you to modify a single dialog file, not projects with several files.

### Brief Introduction

Monologue is a dialog system that allows you to create and edit dialogs for your Godot games. It is a fork of an untitled dialog system by Amberlim.


### Brief Steps to Start Your Story
1. Create or open a `.json` file.
2. Create your dialogues with the various nodes
3. Save the project for use in your story
4. Save the file and use it in your game


### Types of nodes
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

- **End Path Node**<br>
	This node represents the end of a path. It can be interpreted as an exit of the file.

- **Bridge Node**<br>
	- The Bridge node creates a connection between two nodes, when you create a Bridge node, two nodes appear, a BridgeInNode and a BridgeOutNode.
	- The `BridgeInNode` is the link's input node, and the `BridgeOutNode` is the link's exit node.
	- The modifiable number is the link number.


### The JSON file format
```json
{
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


### How it's interpreted
You can write your own script or use [this one]() (not yet written).

This how the end of a branch is interpreted.
If there is no EndPathNode, the next node is the last NodeChoice
![end_path_system](./doc/end_path.png)


### More Support
Hop into the Amberlim's Discord to share your project: https://discord.gg/AAcKmJz7Na
