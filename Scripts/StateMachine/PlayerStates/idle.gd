extends PlayerState
class_name PlayerIdleState

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(idle_anim)
	

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump"): return get_state("Jump")
	if event.is_action_pressed("crouch"): return get_state("Crouch")
	if event.is_action_pressed("parry"): return get_state("Parry")
	
	return attack_inputs(event)

func process_physics(delta: float) -> State:
	if get_move_dir() != 0:
		return get_state("Walk")
	
	if player.input_crouch:
		return get_state("Crouch")
		
	if player.input_parry:
		return get_state("Parry")
		
	return super(delta)
