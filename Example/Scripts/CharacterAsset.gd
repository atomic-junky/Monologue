extends TextureRect


func undisplay():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:x", 1173, .5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func display():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:x", 622, .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
