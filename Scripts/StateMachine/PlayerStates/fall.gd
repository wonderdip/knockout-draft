extends PlayerState
class_name PlayerFallState

@export var air_speed: float = 75

func enter() -> void:
	player.animation_player.play(fall_anim)

func process_physics(delta):
	player.velocity.x = get_move_dir() * air_speed
	if player.is_on_floor():
		return get_state("Landing")
			
	return super(delta)
	
