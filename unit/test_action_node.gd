extends GdUnitTestSuite


var action_node: ActionNode


func before_test():
	action_node = auto_free(ActionNode.new())
	var graph_runner = scene_runner("res://common/layouts/graph_edit/monologue_graph_edit.tscn")
	graph_runner.invoke("add_child", action_node)
	
	action_node.arg_box = VBoxContainer.new()
	action_node.add_child(action_node.arg_box)
	action_node.action_label = mock(Label)
	action_node.no_args_label = mock(Label)


func test_from_dict():
	var arg1_dict = {
		"Name": "first_argument",
		"Type": "Variable",
		"Value": "my_variable_name"
	}
	var arg2_dict = {
		"Name": "second_argument",
		"Type": "Boolean",
		"Value": true
	}
	
	action_node._from_dict({
		"$type": "NodeAction",
		"ID": "test_v3_id",
		"NextID": "next_v3_id",
		"Action": "my_function_name",
		"Arguments": [arg1_dict, arg2_dict]
	})
	action_node.load_arguments(action_node.arguments.value)
	assert_str(action_node.action.value).is_equal("my_function_name")
	assert_dict(action_node.get_arguments()[0]._to_dict()).is_equal(arg1_dict)
	assert_dict(action_node.get_arguments()[1]._to_dict()).is_equal(arg2_dict)


func test_arguments_to_dict():
	var arg1_dict = {
		"Name": "the_first_argument",
		"Type": "Integer",
		"Value": -24
	}
	var arg1 = action_node.add_argument(arg1_dict)
	var arg2 = action_node.add_argument()
	action_node.load_arguments([arg1._to_dict(), arg2._to_dict()])
	
	var test_dict = {}
	action_node._to_fields(test_dict)
	assert_dict(test_dict).contains_keys(["Arguments"])
	
	var args = test_dict.get("Arguments", [])
	assert_array(args).is_equal([arg1_dict, {
		"Name": "",
		"Type": "Boolean",
		"Value": false
	}])
