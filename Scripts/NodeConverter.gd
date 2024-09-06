## Converts v2.x node data into v3.x node data for loading old projects.
class_name NodeConverter extends RefCounted


## Reads raw node data and returns a node instance of the new type.
## Returns the original dictionary if nothing to convert.
func convert_node(node_dict: Dictionary) -> Dictionary:
	match node_dict.get("$type"):
		"NodeAction": return convert_action(node_dict)
	return node_dict


func convert_action(dict: Dictionary) -> Dictionary:
	var action_dict = dict.get("Action")
	var value = action_dict.get("Value")
	dict.erase("Action")
	
	var action_type = action_dict.get("$type")
	match action_type:
		"ActionOption":
			dict["$type"] = "NodeSetter"
			dict["SetType"] = "Option"
			dict["OptionID"] = action_dict.get("OptionID")
			dict["Enable"] = value
		"ActionVariable":
			dict["$type"] = "NodeSetter"
			dict["SetType"] = "Variable"
			dict["Variable"] = action_dict.get("Variable")
			dict["Operator"] = action_dict.get("Operator")
			dict["Value"] = value
		"ActionCustom":
			match action_dict.get("CustomType"):
				"PlayAudio":
					dict["$type"] = "NodeAudio"
					dict["Loop"] = action_dict.get("Loop")
					dict["Volume"] = action_dict.get("Volume")
					dict["Pitch"] = action_dict.get("Pitch")
					dict["Audio"] = value
				"UpdateBackground":
					dict["$type"] = "NodeBackground"
					dict["Image"] = value
				"Other":
					dict["$type"] = "NodeCaller"
					dict["Action"] = value
		"ActionTimer":
			dict["$type"] = "NodeTimer"
			dict["Amount"] = value
	
	return dict
