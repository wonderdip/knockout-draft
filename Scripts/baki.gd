extends CharacterBody2D
class_name Player

@export var fighter_name: String = ""
@export var damage: float

@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: CollisionShape2D = $Hurtbox

func _ready() -> void:
	state_machine.init()

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
func _input(event: InputEvent) -> void:
	state_machine.process_input(event)
	
