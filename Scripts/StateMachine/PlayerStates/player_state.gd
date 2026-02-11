extends State
class_name PlayerState

@onready var player: Player = get_tree().get_first_node_in_group("Player")

#Animation Names
var idle_anim: String = "idle"
var walk_anim: String = "walk"
var jump_anim: String = "jump"
var fall_anim: String = "fall"
var light_punch_anim: String = "light_punch"

#Input Keys
var movement_key: String = "movement"
var left_key: String = "left"
var right_key: String = "right"
var jump_key: String = "jump"
var light_punch_key: String = "light_punch"


var gravity: float = 300

func get_state(name: String) -> PlayerState:
	return state_machine.states[name]

func enter() -> void:
	print(name)
	
func process_physics(delta: float) -> State:
	player.velocity.y += gravity * delta
	
	if (player.velocity.y > 0 and 
	not player.is_on_floor() and 
	not state_machine.current_state == get_state("Fall")):
		return get_state("Fall")
		
	player.move_and_slide()
		
	return null
	
func get_move_dir() -> float:
	return Input.get_axis(left_key, right_key)
