extends PlayerAttackState
class_name PlayerSpecialTwoState

func enter() -> void:
	super()
	player.animation_player.play(special_two_anim)

func exit() -> void:
	super()
	player.attack_box_collision_shape.shape.radius = 10

func process_physics(delta):
	if finished:
		return get_state("Idle")
	return super(delta)
