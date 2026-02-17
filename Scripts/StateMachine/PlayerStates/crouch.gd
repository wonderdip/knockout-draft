extends PlayerState
class_name PlayerCrouchState

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(crouch_anim)
	
func exit() -> void:
	player.hurtbox_collision_shape.position = Vector2(0, 0)
	player.hitbox.position = Vector2(0, 0)
	player.hitbox.shape.height = 74.0
	
func process_input(event: InputEvent) -> State:
	if event.is_action_released("crouch"): return get_state("Idle")
	if event.is_action_pressed("light_punch"): return get_state("CrouchLightPunch")
	if event.is_action_pressed("strong_punch"): return get_state("CrouchStrongPunch")
	if event.is_action_pressed("parry"): return get_state("CrouchParry")
	if event.is_action_pressed("hurt"): return get_state("CrouchHurt")
	return null
	
func process_physics(delta: float) -> State:
	if Input.is_action_pressed("parry"): return get_state("CrouchParry")
	return super(delta)
