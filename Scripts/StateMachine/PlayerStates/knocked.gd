extends PlayerState
class_name PlayerKnockedState

var finished = false

func enter() -> void:
	finished = false
	player.velocity.x = 0.0
	player.animation_player.play(knocked_anim)
	
func process_physics(delta: float) -> State:
	return super(delta)
