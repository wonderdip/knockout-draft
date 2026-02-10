extends PlayerState
class_name PlayerLightPunchState

var finished := false

func enter():
	finished = false
	player.animation_player.play(light_punch_anim)
	player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func _on_anim_finished(anim_name: StringName):
	finished = true

func process_physics(delta):
	if finished:
		return get_state("Idle")
	return super(delta)
