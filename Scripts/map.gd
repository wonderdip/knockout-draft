extends Node2D
class_name Map

@onready var camera_2d: CamShake = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HitEffects.register_camera(camera_2d)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
