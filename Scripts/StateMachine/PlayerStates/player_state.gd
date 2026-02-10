extends State
class_name PlayerState

@onready var player: Player = get_tree().get_first_node_in_group("Player")

#Animation Names
var idle_anim: String = "idle"
var walk_anim: String = "walk"
var light_punch_anim: String = "light_punch"

#Input Keys
var movement_key: String = "movement"
var left_key: String = "left"
var right_key: String = "right"
var light_punch_key: String = "light_punch"

var gravity: float = 500

func get_state(name: String) -> PlayerState:
	return state_machine.states[name]

func process_physics(delta: float) -> State:
	player.velocity.y += gravity * delta
	player.move_and_slide()
	return null
