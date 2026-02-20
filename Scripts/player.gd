extends CharacterBody2D
class_name Fighter

@export var fighter_name: String = ""
@export var state_machine: StateMachine
@export var camera: CamShake

@export_group("Stats")
@export var max_health: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_speed: float = 1.0
@export var max_stamina: int = 100
@export var stamina_gain: float = 10.0  # Stamina per second
var player_number: int = 0
var device_id: int = 0

var is_invincible: bool = false
var facing_direction: int = 1  # 1 = right, -1 = left
var current_health: float = 100.0

var input_crouch := false
var input_parry := false
var input_jump := false

var input_up := false
var input_down := false

var stamina := 100.0

func use_stamina(amount: float) -> bool:
	if stamina < amount:
		return false
	stamina -= amount
	return true
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	stamina = min(max_stamina, stamina + stamina_gain * delta)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
func _input(event: InputEvent) -> void:
	if event.device != device_id:
		return
	
	if event.is_action_pressed("crouch"):
		input_crouch = true
	if event.is_action_released("crouch"):
		input_crouch = false
		
	if event.is_action_pressed("parry"):
		input_parry = true
	if event.is_action_released("parry"):
		input_parry = false
		
	if event.is_action_pressed("jump"):
		input_jump = true
	if event.is_action_released("jump"):
		input_jump = false
		
	if event.is_action_pressed("up"):
		input_up = true
	if event.is_action_released("up"):
		input_up = false
		
	#if event.is_action_pressed("down"):
		#input_down = true
	#if event.is_action_released("down"):
		#input_down = false
	
	state_machine.process_input(event)
