extends PlayerAttackState
class_name PlayerJumpPunchState

func enter() -> void:
	super()
	player.animation_player.play(jump_punch_anim)

func exit() -> void:
	super()
	player.hurtbox_collision_shape.position = Vector2(0, 0)
	player.hitbox.position = Vector2(0, 0)
	player.hitbox.shape.height = 74.0
	

func process_physics(delta):
	if finished:
		return get_state("Fall")
	if player.is_on_floor():
		return get_state("Idle")
	return super(delta)
