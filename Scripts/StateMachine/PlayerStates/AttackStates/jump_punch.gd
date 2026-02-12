extends PlayerAttackState
class_name PlayerJumpPunchState

func enter() -> void:
	super()
	player.animation_player.play(jump_punch_anim)

func process_physics(delta):
	if finished:
		return get_state("Fall")
	return super(delta)
