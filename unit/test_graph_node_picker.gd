extends GdUnitTestSuite


func test_enable_picker_mode():
	var from = "Omelette du Fromage"
	var port = 4
	var release = Vector2(-100.05, 100.09)
	var center = Vector2(123.456, -123.456)
	
	var runner = scene_runner("res://common/windows/graph_node_picker/graph_node_picker.tscn")
	var switcher = mock(GraphEditSwitcher)
	var fake_graph = mock(MonologueGraphEdit)
	fake_graph.file_path = "path present!"
	do_return(fake_graph).on(switcher).get_current_graph_edit()
	
	runner.set_property("switcher", switcher)
	runner.invoke("set_visible", false)
	runner.invoke("_on_enable_picker_mode", from, port, release, null, center)
	
	assert_str(runner.get_property("from_node")).is_equal(from)
	assert_int(runner.get_property("from_port")).is_equal(port)
	assert_vector(runner.get_property("center")).is_equal(center)
	assert_vector(runner.get_property("release")).is_equal(release)
	assert_bool(runner.get_property("visible")).is_true()


func test_enable_picker_mode_invalid_graph():
	var runner = scene_runner("res://common/windows/graph_node_picker/graph_node_picker.tscn")
	var switcher = mock(GraphEditSwitcher)
	var fake_graph = mock(MonologueGraphEdit)
	do_return(fake_graph).on(switcher).get_current_graph_edit()
	runner.set_property("switcher", switcher)
	runner.invoke("_on_enable_picker_mode", "", 0,
			Vector2.ONE, Vector2.ZERO, Vector2.ZERO)
	assert_bool(runner.get_property("visible")).is_false()


func test_close():
	var selector = auto_free(GraphNodePicker.new())
	selector.visible = true
	selector.close()
	assert_bool(selector.visible).is_false()
