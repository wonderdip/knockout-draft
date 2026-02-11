extends PlayerAttackState
class_name PlayerLightPunchState


func enter():
	super()
	print("light_punch")
	player.animation_player.play(light_punch_anim)

func process_physics(delta):
	if finished:
		return get_state("Walk")
	return super(delta)
