extends PlayerState
class_name PlayerWalkState

@export var speed: float = 100

func enter() -> void:
	print("walk")
	player.animation_player.play(walk_anim)

func exit() -> void:
	player.velocity.x = 0.0

func process_physics(delta):
	player.velocity.x = get_move_dir() * speed
	if get_move_dir() == 0:
		return get_state("Idle")
		
	return super(delta)

	
func get_move_dir() -> float:
	return Input.get_axis(left_key, right_key)
	
