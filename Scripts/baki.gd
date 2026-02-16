extends CharacterBody2D
class_name Player

@export var fighter_name: String = ""
@export var camera: CamShake

@export_group("Stats")
@export var max_health: float = 100.0

@export var damage_multiplier: float = 1.0
@export var attack_speed: float = 1.0

@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox_area: Area2D = $HurtboxArea
@onready var hurtbox_collision_shape: CollisionShape2D = $HurtboxArea/HurtboxCollisionShape
@onready var attack_box: Area2D = $AttackBox
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var sprite_2d: Sprite2D = $Sprite2D

var is_invincible: bool = false
var facing_direction: int = 1  # 1 = right, -1 = left
var current_health: float = 100.0

func _ready() -> void:
	state_machine.init()
	animation_player.speed_scale = attack_speed
	current_health = max_health
	
	# Register camera with HitEffects singleton
	if camera:
		HitEffects.register_camera(camera)
	
	# Connect signals
	attack_box.area_entered.connect(_on_attack_hit)
	hurtbox_area.area_shape_entered.connect(_on_hurtbox_hit)
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
func _input(event: InputEvent) -> void:
	state_machine.process_input(event)

## Called when player's attack connects with target
func _on_attack_hit(area: Area2D) -> void:
	var current_state = state_machine.current_state
	
	if current_state is PlayerAttackState:
		var attack_state = current_state as PlayerAttackState
		HitEffects.play_hit_effect(attack_state.hit_strength)
		
		# Apply damage to target if it has a take_damage method
		var target = area.get_parent()
		if target and target.has_method("take_damage"):
			target.take_damage(attack_state.damage * damage_multiplier, self)

## Called when player gets hit
func _on_hurtbox_hit(area: Area2D) -> void:
	# Ignore if invincible or already in hurt state
	if is_invincible or state_machine.current_state is PlayerHurtState:
		return
	
	# Get the attacker
	var attacker = area.get_parent()
	if not attacker or not attacker.has_method("get_attack_damage"):
		return
	
	# Take damage
	var damage = attacker.get_attack_damage()
	take_damage(damage, attacker)

func get_attack_damage() -> float:
	var attack_state = state_machine.current_state
	if attack_state is PlayerAttackState:
		return attack_state.damage
		
	return 0.0

## Take damage and transition to hurt state
func take_damage(damage: float, attacker: Variant) -> void:
	if is_invincible:
		return
	
	current_health -= damage
	current_health = max(0, current_health)
	
	# Emit signal for UI updates
	if has_signal("health_changed"):
		emit_signal("health_changed", current_health, max_health)
	
	# Check for death
	if current_health <= 0:
		die()
		return
	
	# Transition to hurt state
	var hurt_state = state_machine.states.get("Hurt")
	if hurt_state:
		# Store attacker position for knockback calculation
		hurt_state.attacker_position = attacker.global_position
		state_machine.change_state(hurt_state)

## Handle death
func die() -> void:
	print(fighter_name + " has been defeated!")
	# Transition to death/KO state or restart scene
	# You can implement this later

## Set invincibility state
func set_invincible(invincible: bool) -> void:
	is_invincible = invincible
	
	# Optionally change hurtbox collision layer during invincibility
	if invincible:
		hurtbox_collision_shape.set_deferred("disabled", true)
	else:
		hurtbox_collision_shape.set_deferred("disabled", false)

## Heal the player
func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	if has_signal("health_changed"):
		emit_signal("health_changed", current_health, max_health)

# Signal for health changes
signal health_changed(new_health: float, max_health: float)
