extends Node2D
class_name StateMachine

@export var starting_state: State
@export var player: Player
var states : Dictionary[String, State] = {}
var current_state: State


func init() -> void:
	_collect_states(self)
	change_state(starting_state)

func _collect_states(node: Node) -> void:
	for child in node.get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child.player = player
			
		_collect_states(child)

func process_frame(delta: float) -> void:
	var new_state: State = current_state.process_frame(delta)
	if new_state: change_state(new_state)
	
func process_input(event: InputEvent) -> void:
	var new_state: State = current_state.process_input(event)
	if new_state: change_state(new_state)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_physics(delta: float) -> void:
	var new_state: State = current_state.process_physics(delta)
	if new_state: change_state(new_state)

func change_state(new_state: State) -> void:
	if current_state: current_state.exit()
	current_state = new_state
	current_state.enter()
	print(current_state.name)
