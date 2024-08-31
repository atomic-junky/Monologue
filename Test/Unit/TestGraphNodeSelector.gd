extends GdUnitTestSuite


var buttons = [
	["SentenceSelector"], ["ChoiceSelector"], ["DiceRollSelector"], 
	["BridgeSelector"], ["ConditionSelector"], 
	["ActionSelector"], ["EndPathSelector"]
]


@warning_ignore("unused_parameter")
func test_pressed_signal_connected(node: String, test_parameters = buttons):
	var s = scene_runner("res://Objects/SubComponents/GraphNodeSelector.tscn")
	var button = s.find_child(node)
	var connection = button.get_signal_connection_list("pressed")[0]
	var signature = str(connection.get("signal"))
	var callback = str(connection.get("callable"))
	assert_str(signature).ends_with("[signal]pressed")
	assert_str(callback).ends_with("_on_selector_btn_pressed")


func test_enable_picker_mode():
	var from = "Omelette du Fromage"
	var port = 4
	var release = Vector2(-100.05, 100.09)
	var center = Vector2(123.456, -123.456)
	
	var selector = auto_free(GraphNodeSelector.new())
	selector.visible = false
	selector.enable_picker_mode(from, port, release, center)
	assert_str(selector.node).is_equal(from)
	assert_int(selector.port).is_equal(port)
	assert_vector(selector.location).is_equal(center)
	assert_vector(selector.position).is_equal(Vector2i(-150, 100))
	assert_bool(selector.visible).is_true()


func test_disable_picker_mode():
	var selector = auto_free(GraphNodeSelector.new())
	selector.visible = true
	selector.disable_picker_mode()
	assert_bool(selector.visible).is_false()
