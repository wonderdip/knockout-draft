extends State
class_name PlayerState

var player: Player

#Animation Names
var idle_anim: String = "idle"
var walk_anim: String = "walk"
var jump_anim: String = "jump"
var fall_anim: String = "fall"
var crouch_anim: String = "crouch"
var parry_anim: String = "parry"
var crouch_parry_anim: String = "crouch_parry"

#Input Keys
var movement_key: String = "movement"
var left_key: String = "left"
var right_key: String = "right"

var gravity: float = 300

func get_state(state_name: String) -> PlayerState:
	return state_machine.states[state_name]

func attack_inputs(event: InputEvent) -> State:
	if event.is_action_pressed("light_punch"): return get_state("LightPunch")
	
	if event.is_action_pressed("strong_punch"):
		if Input.is_action_pressed("up"):
			return get_state("Uppercut")
		return get_state("StrongPunch")
		
	if event.is_action_pressed("kick"):
		if Input.is_action_pressed("up"):
			return get_state("HighKick")
		return get_state("Kick")
		
	return null
	
func enter() -> void:
	print(name)
	
func process_physics(delta: float) -> State:
	player.velocity.y += gravity * delta
		
	player.move_and_slide()
		
	return null
	
func get_move_dir() -> float:
	return Input.get_axis(left_key, right_key)
