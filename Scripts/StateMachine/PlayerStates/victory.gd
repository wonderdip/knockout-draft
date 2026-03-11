extends PlayerState
class_name PlayerVictoryState

var finished = false

func enter() -> void:
	finished = false
	player.velocity.x = 0.0
	player.z_index = 10
	player.animation_player.play(victory_anim)
	
	player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func _on_anim_finished(_anim_name: StringName):
	finished = true
	player.z_index = 1
	player.died.emit(player.other_fighter.player_number)
	
func process_physics(delta: float) -> State:
	if finished:
		return get_state("Idle")
	return null
	
