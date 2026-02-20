extends PlayerState
class_name PlayerWalkState

@export var speed: float = 100

func enter() -> void:
	player.animation_player.play(walk_anim)

func exit() -> void:
	player.velocity.x = 0.0

func process_physics(delta):
	player.velocity.x = get_move_dir() * speed
	if get_move_dir() == 0.0:
		return get_state("Idle")
		
	return super(delta)
	
func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump"): 
		var deadzone := 0.8
		var axis = Input.get_joy_axis(player.device_id, JOY_AXIS_LEFT_Y)
		if abs(axis) < deadzone:
			return get_state("Jump")
			
	if event.is_action_pressed("parry"): return get_state("Parry")
	return attack_inputs(event)
	
