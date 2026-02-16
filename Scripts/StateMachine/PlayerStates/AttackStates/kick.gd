extends PlayerAttackState
class_name PlayerKickState

func enter():
	super()
	player.animation_player.play(kick_anim)

func process_physics(delta):
	if finished:
		return get_state("Walk")
	return super(delta)
