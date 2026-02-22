extends PlayerAttackState
class_name PlayerCrouchAttackState

var crouch_light_punch_anim: String = "crouch_light_punch"
var crouch_strong_punch_anim: String = "crouch_strong_punch"
var crouch_light_kick_anim: String = "crouch_light_kick"
var crouch_strong_kick_anim: String = "crouch_strong_kick"

func exit() -> void:
	print("uncrouching")
	player.hurtbox_collision_shape.position = Vector2(0, 0)
	player.hitbox.position = Vector2(0, 0)
	player.hitbox.shape.height = 74.0
	
func _on_anim_finished(_anim_name: StringName):
	finished = true
