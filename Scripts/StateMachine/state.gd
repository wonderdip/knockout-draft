extends Node2D
class_name State

var state_machine: StateMachine

func enter() -> void:
	pass
func exit() -> void:
	pass
	
func process_frame(delta: float) -> State:
	return null

func process_input(event: InputEvent) -> State:
	return null
# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_physics(delta: float) -> State:
	return null
