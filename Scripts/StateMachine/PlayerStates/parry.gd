extends PlayerState
class_name PlayerParryState

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(parry_anim)
	
func process_input(event: InputEvent) -> State:
	if event.is_action_released("parry"): return get_state("Idle")
	if event.is_action_pressed("crouch"):
		return get_state("CrouchParry")
	return null
	
func process_physics(delta: float) -> State:
	player.stamina = min(player.max_stamina, player.stamina - player.stamina_gain * 3 * delta)
	return null
