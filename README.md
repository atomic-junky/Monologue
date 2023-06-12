# GodotDialogSystem 🦖
A fork of an untitled godot dialog system waiting to be named a cool name. (for Godot 4.x)

This system converts your story/dialog into a JSON file which you can then use to create your dialog in game.
The app this application allows you to modify a single dialog file, not projects with several files.


### Brief Steps to Start Your Story
1. Open or create a `.json` file (the file must have the correct format)
2. Create your dialogues with the various nodes
3. Save the project for use in your story


### Types of nodes
 - **Root Node**<br>
    There is only one in each file, and it cannot be deleted. The Root Node is the starting point of your story

- **Sentence Node**<br>
    Sentence nodes represent a character's dialogue sentence.

- **Choice Node**<br>
    It's a node that allows the user to make choices and then select a specific branch. A Choice Node has several Option Nodes.

- **Option Node**<br>
    An Option Node has several parameters:<br>
    - **Enable by default**: the first time the user is confronted with the Choice Node.
    - **One Shot**: this option is valid only once

- **End Path Node**<br>
    This node represents the end of a path. It can be interpreted as an exit of the file


### How it's interpreted
You can write your own script or use [this one]() (not yet written).

This how the end of a branch is interpreted.
If there is no EndPathNode, the next node is the last NodeChoice
![end_path](end_path.png)


### More Support
Hop into the Amberlim's Discord to share your project: https://discord.gg/AAcKmJz7Na
