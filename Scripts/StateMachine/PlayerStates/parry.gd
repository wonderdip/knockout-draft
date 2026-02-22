extends PlayerState
class_name PlayerParryState

func enter() -> void:
	var cost = 10
	if not player.use_stamina(cost):
		return # Cancel attack if not enough stamina
		
	player.velocity.x = 0.0
	player.animation_player.play(parry_anim)
	
func process_input(event: InputEvent) -> State:
	if event.is_action_released("parry"): return get_state("Idle")
	if event.is_action_pressed("crouch"):
		return get_state("CrouchParry")
	return null
	
