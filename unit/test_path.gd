extends GdUnitTestSuite


var linux_file = "/home/mrsharpener/Pen/1_n.json"
var linux_params = [
	["/home/mrsharpener/Pen/w/b/20/ac.mp3", "w/b/20/ac.mp3"],
	["/home/mrsharpener/Pen/1.txt", "1.txt"],
	["/home/missyeraser/K/y.o.u", "../../missyeraser/K/y.o.u"],
	["/opt/x/1/bro", "/opt/x/1/bro"],
]

var windows_file = "C:\\Users\\MrSharpener\\Pen\\1_n.json"
var windows_params = [
	["C:\\Users\\MrSharpener\\Pen\\w\\b\\20\\ac.mp3", "w/b/20/ac.mp3"],
	["C:\\Users\\MrSharpener\\Pen\\1.txt", "1.txt"],
	["C:\\Users\\MissyEraser\\K\\y.o.u", "../../MissyEraser/K/y.o.u"],
	["E:\\10. __World\\g1d a", "E:\\10. __World\\g1d a"],
]


func reverse_parameters(params: Array):
	var copy = params.duplicate()
	copy.reverse()
	return copy.map(func(s: String): return s.replace("\\", "/"))


@warning_ignore("unused_parameter")
func test_absolute_to_relative_linux(path: String, result: String,
		test_parameters = linux_params):
	assert_str(Path.absolute_to_relative(path, linux_file)).is_equal(result)


@warning_ignore("unused_parameter")
func test_absolute_to_relative_windows(path: String, result: String,
		test_parameters = windows_params):
	assert_str(Path.absolute_to_relative(path, windows_file)).is_equal(result)


@warning_ignore("unused_parameter")
func test_relative_to_absolute_linux(path: String, result: String,
		test_parameters = linux_params.map(reverse_parameters)):
	assert_str(Path.relative_to_absolute(path, linux_file)).is_equal(result)


@warning_ignore("unused_parameter")
func test_relative_to_absolute_windows(path: String, result: String,
		test_parameters = windows_params.map(reverse_parameters)):
	assert_str(Path.relative_to_absolute(path, windows_file)).is_equal(result)
