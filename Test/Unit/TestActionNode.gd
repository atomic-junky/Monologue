extends GdUnitTestSuite


var action_node: ActionNode


func before_test():
	action_node = auto_free(ActionNode.new())


func test_from_dict():
	action_node.action_type_label = auto_free(Label.new())
	action_node.custom_container = auto_free(Control.new())
	action_node.loop_value_container = auto_free(Control.new())
	action_node.option_container = auto_free(Control.new())
	action_node.variable_container = auto_free(Control.new())
	action_node.timer_container = auto_free(Control.new())
	action_node.custom_type_label = auto_free(Label.new())
	action_node.custom_value_label = auto_free(Label.new())
	
	var data = {
		"$type": "NodeAction",
		"ID": "123-action",
		"NextID": "123-sentence",
		"Action": {
			"$type": "ActionCustom",
			"CustomType": "Other",
			"Value": "death"
		},
		"EditorPosition": {
			"x": 142,
			"y": -83
		}
	}
	
	action_node._from_dict(data)
	assert_str(action_node.action_type).is_equal("ActionCustom")
	assert_str(action_node.custom_type).is_equal("Other")
	assert_str(action_node.value).is_equal("death")
