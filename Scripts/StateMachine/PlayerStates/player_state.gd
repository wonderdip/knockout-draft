extends State
class_name PlayerState

var player: Fighter

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
	if event.is_action_pressed("strong_punch"): return get_state("StrongPunch")
		
	if event.is_action_pressed("light_kick"): return get_state("Kick")
	if event.is_action_pressed("strong_kick"): return get_state("HighKick")
		
	return null

	
func process_physics(delta: float) -> State:
	player.velocity.y += gravity * delta
		
	player.move_and_slide()
		
	return null
	
func get_move_dir() -> float:
	var left  := Input.is_joy_button_pressed(player.device_id, JOY_BUTTON_DPAD_LEFT)
	var right := Input.is_joy_button_pressed(player.device_id, JOY_BUTTON_DPAD_RIGHT)

	if right:
		return 1.0
	elif left:
		return -1.0
	
	return 0.0
