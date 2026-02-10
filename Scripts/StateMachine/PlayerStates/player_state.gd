extends State
class_name PlayerState

@onready var player: Player = get_tree().get_first_node_in_group("Player")

#Animation Names
var idle_anim: String = "idle"
var walk_anim: String = "walk"

#States
@export_group("States")
@export var idle_state: PlayerState
@export var walk_state: PlayerState

#Input Keys
var movement_key: String = "movement"
var left_key: String = "left"
var right_key: String = "right"

var gravity: float = 500

func process_physics(delta: float) -> State:
	player.velocity.y += gravity * delta
	player.move_and_slide()
	return null
