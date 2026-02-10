extends PlayerState
class_name PlayerIdleState

func enter() -> void:
	print("idle")
	player.animation_player.play(idle_anim)

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("movement"): return get_state("Walk")
	if event.is_action_pressed("light_punch"): return get_state("LightPunch")
	return null
