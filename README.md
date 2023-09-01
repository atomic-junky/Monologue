# Monologue 🦖

### About
Monologue is a powerful tool that allows you to create and edit dialogues in a node editor and then save them as a JSON file so you can use them anywhere.

You can find the doc [here](https://crewsaders.gitbook.io/monologue/).


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

- **End Path Node**<br>
	This node represents the end of a path. It can be interpreted as an exit of the file.

- **Bridge Node**<br>
	- The Bridge node creates a connection between two nodes, when you create a Bridge node, two nodes appear, a BridgeInNode and a BridgeOutNode.
	- The `BridgeInNode` is the link's input node, and the `BridgeOutNode` is the link's exit node.
	- The modifiable number is the link number.


## The JSON file format
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


## How it's interpreted
You can write your own script or use the one in the example (MonologueProcess.gd).

More soon.


## More Support
This project is originally from Amberlim, so if you want, here is her [Discord server](https://discord.gg/AAcKmJz7Na). However, if you need help, don't hesitate to create an issue on Github.
