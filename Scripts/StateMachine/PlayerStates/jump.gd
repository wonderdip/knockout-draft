extends PlayerState
class_name PlayerJumpState

@export var air_speed: float = 75
@export var jump_force: float = 75

func enter() -> void:
	player.velocity.y = -jump_force
	player.animation_player.play(jump_anim)

func process_physics(delta):
	player.velocity.x = get_move_dir() * air_speed
		
	return super(delta)
	

	
