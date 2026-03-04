extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var scenes: Dictionary[String, PackedScene] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.hide()

func change_scene(scene: PackedScene):
	color_rect.show()
	animation_player.play("exit")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(scene)
	Global.start_game()
	animation_player.play("enter")
