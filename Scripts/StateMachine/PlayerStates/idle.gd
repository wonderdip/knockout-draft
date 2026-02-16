extends PlayerState
class_name PlayerIdleState

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(idle_anim)
	

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump"): return get_state("Jump")
	if event.is_action_pressed("crouch"): return get_state("Crouch")
	if event.is_action_pressed("parry"): return get_state("Parry")
	if event.is_action_pressed("hurt"): return get_state("Hurt")
	
	return attack_inputs(event)

func process_physics(delta: float) -> State:
	if get_move_dir() != 0:
		return get_state("Walk")
	
	if Input.is_action_pressed("crouch"): return get_state("Crouch")
	
	return super(delta)
