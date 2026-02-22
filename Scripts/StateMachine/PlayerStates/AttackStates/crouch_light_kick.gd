extends PlayerCrouchAttackState
class_name PlayerCrouchLightKickState

func enter() -> void:
	super()
	player.velocity.x = 0.0
	player.animation_player.play(crouch_strong_kick_anim)

func process_physics(delta):
	if finished:
		if Input.is_action_pressed("crouch"):
			return get_state("Crouch")
		else:
			return get_state("Idle")
	return super(delta)
