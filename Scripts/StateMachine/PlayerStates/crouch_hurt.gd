extends PlayerHurtState
class_name PlayerCrouchHurtState

func _init():
	hurt_animation = "crouch_hurt"

func enter() -> void:
	super()

func exit() -> void:
	super()
	# Reset hurtbox to standing position when leaving state
	player.hitbox.position = Vector2(0, 0)
	player.hurtbox_collision_shape.position = Vector2(0, 0)
	player.hurtbox_collision_shape.shape.height = 74.0

## Override to return to crouch instead of idle
func get_next_state() -> State:
	if player.is_on_floor():
		if Input.is_action_pressed("crouch"):
			return get_state("Crouch")
		else:
			return get_state("Idle")
	else:
		return get_state("Fall")
