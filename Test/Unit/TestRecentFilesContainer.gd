extends GdUnitTestSuite


var container: RecentFilesContainer
var directory


func before_test():
	container = auto_free(RecentFilesContainer.new())
	container.button_container = auto_free(Control.new())
	container.button_scene = \
			preload("res://Objects/SubComponents/RecentFileButton.tscn")
	container.save_path = "user://test_history.save"
	directory = DirAccess.open(container.save_path.get_base_dir())
	directory.remove(container.save_path)


func test_add_from_empty():
	container.add("whatever.json")
	var text = FileAccess.get_file_as_string(container.save_path)
	assert_str(text).is_equal("[\"whatever.json\"]")


func test_add_override():
	var file = FileAccess.open(container.save_path, FileAccess.WRITE)
	file.store_string('["one.json", "two.json"]')
	file.close()
	container.recent_filepaths = ["three.json", "four.json"]
	container.add("five.json")
	
	var text = FileAccess.get_file_as_string(container.save_path)
	var json = JSON.parse_string(text)
	# test the order of the array, "five.json" should be first!
	assert_array(json).is_equal(["five.json", "three.json", "four.json"])


func test_create_file():
	assert_bool(FileAccess.file_exists(container.save_path)).is_false()
	container.create_file()
	assert_bool(FileAccess.file_exists(container.save_path)).is_true()


func test_load_file_empty():
	container.load_file()
	assert_int(container.button_container.get_child_count()).is_equal(0)


func test_load_file_exclude_not_exist():
	var file = FileAccess.open(container.save_path, FileAccess.WRITE)
	file.store_string('["res://DOES_NOT_EXIST.json", ' + \
			'"res://Examples/mr_sharpener/ending_02.json"]')
	file.close()
	container.load_file()
	assert_int(container.button_container.get_child_count()).is_equal(1)
	for button in container.button_container.get_children():
		button.free()


func test_load_file_existing():
	var file = FileAccess.open(container.save_path, FileAccess.WRITE)
	file.store_string('["res://Examples/mr_sharpener/intro.json", ' + \
			'"res://Examples/mr_sharpener/ending_01.json"]')
	file.close()
	container.load_file()
	assert_int(container.button_container.get_child_count()).is_equal(2)
	for button in container.button_container.get_children():
		button.free()


func after_test():
	directory.remove(container.save_path)
