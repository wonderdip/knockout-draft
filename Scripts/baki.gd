extends CharacterBody2D
class_name Player

@export var fighter_name: String = ""
@export var damage_multiplier: float = 1.0
@export var attack_speed: float = 1.0
@export var camera: CamShake

@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: CollisionShape2D = $Hurtbox

func _ready() -> void:
	state_machine.init()
	animation_player.speed_scale = attack_speed
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
func _input(event: InputEvent) -> void:
	state_machine.process_input(event)

func framefreeze(duration: float, time_scale: float):
	if time_scale > 0:
		Engine.time_scale = time_scale
		await get_tree().create_timer(duration * time_scale, true, false, true).timeout
		Engine.time_scale = 1.0
	else:
		Engine.time_scale = 0
		camera.cam_shake(4, 2, duration)
		await get_tree().create_timer(duration, true, false, true).timeout
		Engine.time_scale = 1.0
