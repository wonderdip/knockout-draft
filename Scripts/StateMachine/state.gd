extends Node2D
class_name State

var state_machine: StateMachine

func enter() -> void:
	pass
func exit() -> void:
	pass
	
func process_frame(_delta: float) -> State:
	return null

func process_input(_event: InputEvent) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
