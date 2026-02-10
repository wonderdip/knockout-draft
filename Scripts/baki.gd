extends CharacterBody2D
class_name Player

@export var fighter_name: String = ""
@export var speed: float
@export var damage: float
@export var jump_height: float

var gravity: float = 500
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	state_machine.init()
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
func _input(event: InputEvent) -> void:
	state_machine.process_input(event)
	
