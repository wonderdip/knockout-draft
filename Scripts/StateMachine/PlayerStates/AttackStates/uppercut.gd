extends PlayerAttackState
class_name PlayerUppercutState

func enter():
	super()
	print("uppercut")
	player.animation_player.play(uppercut_anim)

func process_physics(delta):
	if finished:
		return get_state("Walk")
	return super(delta)
