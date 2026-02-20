extends PlayerState
class_name PlayerLandingState

var finished := false

func enter():
	player.animation_player.play("landing")
	finished = false
	player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func _on_anim_finished(_anim: String):
	finished = true

func process_physics(delta: float) -> State:
	if finished:
		return get_state("Idle")
			
	return super(delta)
