extends PlayerState
class_name PlayerJumpState

@export var air_speed: float = 75
@export var jump_force: float = 75

func enter() -> void:
	player.velocity.y = -jump_force
	player.animation_player.play(jump_anim)

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("light_punch"): return get_state("JumpPunch")
	return null

func process_physics(delta):
	player.velocity.x = get_move_dir() * air_speed
	if (player.velocity.y > 0 and 
	not player.is_on_floor() and 
	not state_machine.current_state == get_state("Fall")):
		return get_state("Fall")
		
	return super(delta)
	

	
