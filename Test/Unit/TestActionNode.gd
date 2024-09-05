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


func test_to_dict():
	#var graph_edit = mock(MonologueGraphEdit, CALL_REAL_FUNC)
	#do_return(["test-action-next"]).on(graph_edit) \
	#		.get_all_connections_from_slot("ActionUnitTestNode", 0)
	
	action_node.action_type = "ActionTimer"
	action_node.id = "test-action-unit"
	action_node.name = "ActionUnitTestNode"
	action_node.value = 5
	#graph_edit.add_child(action_node)
	assert_dict(action_node._to_dict()).is_equal({
		"$type": "NodeAction",
		"ID": "test-action-unit",
		"NextID": "test-action-next",
		"Action": {
			"$type": "ActionTimer",
			"Value": 5
		},
		"EditorPosition": {
			"x": 0,
			"y": 0
		}
	})
