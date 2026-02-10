extends Node2D
class_name State

# Called when the node enters the scene tree for the first time.

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
