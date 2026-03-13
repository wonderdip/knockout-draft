extends TextureButton
class_name MapButton

@export var map: MapResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_SCALE
	custom_minimum_size = Vector2(96, 54)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_normal = map.mini_map

func choose():
	modulate = Color(0.5, 0.5, 0.5)
	
func unchoose():
	modulate = Color.WHITE
