extends PlayerAttackState
class_name PlayerSpecialOneState

func enter() -> void:
	super()
	player.animation_player.play(special_one_anim)

func process_physics(delta):
	if finished:
		return get_state("Idle")
	return super(delta)
