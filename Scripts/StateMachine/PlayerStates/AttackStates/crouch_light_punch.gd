extends PlayerAttackState
class_name PlayerCrouchLightPunchState


func enter() -> void:
	super()
	player.velocity.x = 0.0
	player.animation_player.play(crouch_light_punch_anim)

func exit() -> void:
	super()
	player.hurtbox.position = Vector2(0, 0)
	player.hurtbox.shape.height = 74.0

func process_physics(delta):
	if finished:
		if Input.is_action_pressed("crouch"):
			return get_state("Crouch")
		else:
			return get_state("Idle")
	return super(delta)
