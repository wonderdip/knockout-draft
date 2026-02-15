extends PlayerAttackState
class_name PlayerStrongPunchState

func enter():
	super()
	player.animation_player.play(strong_punch_anim)
	
func process_physics(delta):
	if finished:
		return get_state("Walk")
	return super(delta)
