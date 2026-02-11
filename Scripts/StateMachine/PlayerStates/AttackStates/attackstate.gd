extends PlayerState
class_name PlayerAttackState


var light_punch_anim: String = "light_punch"
var strong_punch_anim: String = "strong_punch"
var crouch_light_punch_anim: String = "crouch_light_punch"
var crouch_strong_punch_anim: String = "crouch_strong_punch"

var finished: bool = false

func enter() -> void:
	finished = false
	player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)
	
func _on_anim_finished(_anim_name: StringName):
	finished = true
