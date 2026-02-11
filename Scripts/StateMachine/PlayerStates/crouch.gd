extends PlayerState
class_name PlayerCrouchState

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(crouch_anim)

func exit() -> void:
	super()
	player.animation_player.play("uncrouch")

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump"): return get_state("Jump")
	if event.is_action_released("crouch"): return get_state("Idle")
	if event.is_action_pressed("light_punch"): return get_state("CrouchLightPunch")
	if event.is_action_pressed("strong_punch"): return get_state("CrouchStrongPunch")
	return null
