extends PlayerState
class_name PlayerVictoryState

var finished = false

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(victory_anim)
	
	player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func _on_anim_finished(_anim_name: StringName):
	finished = true
	player.died.emit(player.other_fighter.player_number)
	
func process_physics(delta: float) -> State:
	if finished:
		return get_state("Idle")
	return null
	
