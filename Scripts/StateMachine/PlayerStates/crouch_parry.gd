extends PlayerState
class_name PlayerCrouchParryState

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(crouch_parry_anim)
	
func exit() -> void:
	super()
	player.hurtbox.position = Vector2(0, 0)
	player.hurtbox.shape.height = 74.0
	
func process_input(event: InputEvent) -> State:
	if event.is_action_released("parry"): return get_state("Crouch")
	if event.is_action_released("crouch") and event.is_action_released("parry"): 
		return get_state("Idle")
	elif event.is_action_released("crouch"):
		return get_state("Parry")
		
	return null
	
