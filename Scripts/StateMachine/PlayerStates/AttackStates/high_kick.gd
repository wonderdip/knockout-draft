extends PlayerAttackState
class_name PlayerHighKickState

func enter():
	super()
	player.animation_player.play(high_kick_anim)

func process_physics(delta):
	if finished:
		return get_state("Walk")
	return super(delta)
