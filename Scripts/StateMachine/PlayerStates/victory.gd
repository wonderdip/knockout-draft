extends PlayerState
class_name PlayerVictoryState

var finished = true

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_player.play(victory_anim)
	
	if not player.animation_player.animation_finished.is_connected(_on_anim_finished):
		player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func _on_anim_finished(_anim_name: StringName):
	player.other_fighter.died.emit(player.other_fighter.player_number)
	
