extends GdUnitTestSuite


var parent_panel: MonologueNodePanel
var accordion: MonologueAccordion


func before_test():
	parent_panel = mock(MonologueNodePanel, CALL_REAL_FUNC)
	accordion = auto_free(MonologueAccordion.new("bunch", "Bundle", "bro"))
	accordion.panel = parent_panel


func test_add_to_dict():
	var f1 = mock(MonologueField, CALL_REAL_FUNC)
	var f2 = mock(MonologueField, CALL_REAL_FUNC)
	var f3 = mock(MonologueField, CALL_REAL_FUNC)
	f3.key = "field_3"
	f3.value = 999
	var f4 = auto_free(Control.new())
	accordion.control_groups[0] = [f1, f2]
	accordion.control_groups[1] = [f3, f4]
	
	var option_button = auto_free(OptionButton.new())
	option_button.add_item("one")
	option_button.add_item("two")
	option_button.select(1)
	accordion.option_button = option_button
	
	var dict = { "existing": "here" }
	accordion.add_to_dict(dict)
	assert_dict(dict).is_equal({
		"existing": "here",
		"Bundle": { "field_3": 999 },
	})


func test_group():
	var c1 = auto_free(Control.new())
	var c2 = auto_free(Control.new())
	var c3 = auto_free(Control.new())
	accordion.group(0, [c1, c2])
	accordion.group(1, [c3])
	
	assert_array(accordion.control_groups.get(0)).is_equal([c1, c2])
	assert_array(accordion.control_groups.get(1)).is_equal([c3])


func test_show_selected():
	var c1 = auto_free(Control.new())
	var c2 = auto_free(Control.new())
	var c3 = auto_free(Control.new())
	var c4 = auto_free(Control.new())
	var c5 = auto_free(Control.new())
	accordion.control_groups[0] = [c1]
	accordion.control_groups[1] = [c2]
	accordion.control_groups[2] = [c3, c4]
	accordion.control_groups[3] = [c5]
	
	var option_button = auto_free(OptionButton.new())
	option_button.add_item("s1")
	option_button.add_item("s2")
	option_button.add_item("s3")
	option_button.add_item("s4")
	option_button.select(2)
	accordion.option_button = option_button

	accordion.show_selected()
	assert_bool(c1.visible).is_false()
	assert_bool(c2.visible).is_false()
	assert_bool(c3.visible).is_true()
	assert_bool(c4.visible).is_true()
	assert_bool(c5.visible).is_false()
