extends GdUnitTestSuite


func test_to_fields():
	var runner = scene_runner("res://Objects/GraphNodes/ChoiceNode.tscn")
	var test_dict = {}
	runner.invoke("_to_fields", test_dict)
	assert_dict(test_dict).contains_keys(["OptionsID"])
	
	var options_id = test_dict.get("OptionsID", [])
	assert_array(options_id).has_size(2)
	assert_bool(options_id[0] is String)
	assert_bool(options_id[1] is String)
