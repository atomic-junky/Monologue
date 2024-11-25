extends GdUnitTestSuite


func test_to_dict():
	var runner = scene_runner("res://nodes/option_node/option_node.tscn")
	runner.get_property("id").value = "12345"
	runner.get_property("option").value = "heyho"
	runner.get_property("one_shot").value = true
	runner.get_property("next_id").value = "abcde"
	
	var result = runner.invoke("_to_dict")
	assert_str(result.get("$type")).is_equal("NodeOption")
	assert_str(result.get("ID")).is_equal("12345")
	assert_str(result.get("Option")).is_equal("heyho")
	assert_bool(result.get("OneShot")).is_true()
	assert_bool(result.get("EnableByDefault")).is_true()
	assert_str(result.get("NextID")).is_equal("abcde")


func test_from_dict_v2():
	var option_node = auto_free(OptionNode.new())
	option_node._from_dict({
		"$type": "NodeOption",
		"ID": "test_v2_id",
		"NextID": "next_v2_id",
		"Sentence": "v2 here",
		"Enable": false,
		"OneShot": true
	})
	
	assert_str(option_node.id.value).is_equal("test_v2_id")
	assert_str(option_node.next_id.value).is_equal("next_v2_id")
	assert_str(option_node.option.value).is_equal("v2 here")
	assert_bool(option_node.enable_by_default.value).is_false()
	assert_bool(option_node.one_shot.value).is_true()


func test_from_dict_v3():
	var option_node = auto_free(OptionNode.new())
	option_node._from_dict({
		"$type": "NodeOption",
		"ID": "test_v3_id",
		"NextID": "next_v3_id",
		"Option": "v3 here",
		"EnableByDefault": false,
		"OneShot": true
	})
	
	assert_str(option_node.id.value).is_equal("test_v3_id")
	assert_str(option_node.next_id.value).is_equal("next_v3_id")
	assert_str(option_node.option.value).is_equal("v3 here")
	assert_bool(option_node.enable_by_default.value).is_false()
	assert_bool(option_node.one_shot.value).is_true()
