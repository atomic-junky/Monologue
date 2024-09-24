extends Node2D
# You can set a custom cursor in engine, and add the different shapes programmatically.
# This is a animated sprite that follows the mouse, 
# the benefit is that this can be animated

## Done like this so we can iterate over them
enum Shapes {
	CURSOR_ARROW,
	CURSOR_IBEAM,
	CURSOR_POINTING_HAND,
	CURSOR_CROSS,
	CURSOR_WAIT,
	CURSOR_BUSY,
	CURSOR_DRAG,
	CURSOR_CAN_DROP,
	CURSOR_FORBIDDEN,
	CURSOR_VSIZE,
	CURSOR_HSIZE,
	CURSOR_BDIAGSIZE,
	CURSOR_FDIAGSIZE,
	CURSOR_MOVE,
	CURSOR_HSPLIT,
	CURSOR_VSPLIT,
	CURSOR_HELP,
	CURSOR_HAND_CLOSED,
}

## Instead of the Input function, use this as it only shows the sprite and never the cursor

@export var sprite: AnimatedSprite2D

@onready var previous_mouse_shape: int = Input.get_current_cursor_shape()

var shape: int = Input.CURSOR_ARROW: set = set_shape
var current_animation: StringName
var current_frame_texture: Texture2D

func _ready():
	sprite.hide()

func _process(_delta: float):
	var current_mouse_shape = Input.get_current_cursor_shape()

	if current_mouse_shape != previous_mouse_shape:
		set_shape(current_mouse_shape)
		previous_mouse_shape = current_mouse_shape

	current_animation = sprite.animation
	current_frame_texture = sprite.sprite_frames.get_frame_texture(
			current_animation, sprite.frame
		)

	Input.set_custom_mouse_cursor(
		current_frame_texture,
		Input.get_current_cursor_shape(),
		sprite.offset
	)

## Gets the CursorShape in a formatted string without the prefix CURSOR_ Mainly used for changing animations
func get_shape_name() -> StringName:
	return Shapes.keys()[shape].to_lower().trim_prefix("cursor_")

func set_shape(value: int) -> void:
	if !sprite: return

	shape = value

	if shape <= - 1:
		shape = Input.CURSOR_ARROW

	var anim_name: StringName = get_shape_name()
	var sprite_frames: SpriteFrames = sprite.sprite_frames

	var has_animation: bool = sprite_frames.has_animation(anim_name)

	if has_animation:
		sprite.play(anim_name)
		sprite.offset = get_offset()
		return
	else:
		push_warning("Animation %s does not exist" % anim_name)

func get_offset() -> Vector2:
	if !current_frame_texture:
		return Vector2.ZERO

	match shape:
		Input.CURSOR_ARROW, Input.CURSOR_POINTING_HAND, Input.CURSOR_ARROW:
			return Vector2.ZERO

	return current_frame_texture.get_size() * 0.5
