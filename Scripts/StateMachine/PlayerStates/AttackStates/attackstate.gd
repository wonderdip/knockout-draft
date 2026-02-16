extends PlayerState
class_name PlayerAttackState

var light_punch_anim: String = "light_punch"
var strong_punch_anim: String = "strong_punch"
var uppercut_anim: String = "uppercut"
var crouch_light_punch_anim: String = "crouch_light_punch"
var crouch_strong_punch_anim: String = "crouch_strong_punch"
var jump_punch_anim: String = "jump_punch"

var kick_anim: String = "kick"
var high_kick_anim: String = "high_kick"


@export var damage: float = 0.0
@export var hit_strength: HitEffects.HitStrength = HitEffects.HitStrength.LIGHT

var finished: bool = false

func enter() -> void:
	finished = false
	player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func exit() -> void:
	var attack_box_shape: CollisionShape2D = player.attack_box.get_child(0)
	attack_box_shape.shape.height = 44

func _on_anim_finished(_anim_name: StringName):
	finished = true
