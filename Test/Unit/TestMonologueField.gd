extends GdUnitTestSuite


var parent_panel: MonologueNodePanel


func before_test():
	parent_panel = mock(MonologueNodePanel, CALL_REAL_FUNC)


func test_line_edit():
	
	var field = auto_free(MonologueLineEdit.new("sentence", "Sentence", "Hi!"))
	field.label("Sentence").build()
	assert_array(field.get_child(0).get_children()).is_equal([])
	
	var picker = auto_free(FilePickerLineEdit.new().get())
	picker.get()
