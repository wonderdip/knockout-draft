extends CharacterBody2D
class_name Fighter

# Signal must be defined at the top!
signal health_changed(new_health: float, max_health: float)
signal died

@export var fighter_name: String = ""
@export var state_machine: StateMachine
@export var camera: DynamicCamera
@export var parry_particle: ParryParticle

@export_group("Stats")
@export var max_health: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_speed: float = 1.0
@export var max_stamina: int = 100
@export var stamina_gain: float = 10.0  # Stamina per second

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox_area: Area2D = $HurtboxArea
@onready var hurtbox_collision_shape: CollisionShape2D = $HurtboxArea/HurtboxCollisionShape
@onready var attack_box: Area2D = $AttackPivot/AttackBox
@onready var attack_box_collision_shape: CollisionShape2D = $AttackPivot/AttackBox/AttackBoxCollisionShape
@onready var attack_pivot: Node2D = $AttackPivot

@onready var hitbox: CollisionShape2D = $Hitbox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ui_layer: CanvasLayer = $UILayer
@onready var mug_shot: Sprite2D = $UILayer/MugShot

var player_number: int = 0
var device_id: int = 0
var other_fighter: Fighter

var is_invincible: bool = false
var facing_direction: int = 1  # 1 = right, -1 = left
var current_health: float = 100.0

var input_crouch := false
var input_parry := false
var input_jump := false

var input_up := false
var input_down := false

var stamina := 100.0

func _ready() -> void:
	print(global_position)
	state_machine.init()
	animation_player.speed_scale = attack_speed
	current_health = max_health
		
	# Connect signals
	attack_box.area_entered.connect(_on_attack_hit)
	hurtbox_area.area_shape_entered.connect(_on_hurtbox_hit)
	
	# Emit initial health for UI
	health_changed.emit(current_health, max_health)
	ui_layer.show()
	
	if player_number == 2:
		ui_layer.scale.x = -1
		mug_shot.scale.x = -1
		ui_layer.offset.x = 320
		sprite_2d.scale.x = -1
		attack_pivot.scale.x = -1
		
## Called when player's attack connects with target
func _on_attack_hit(area: Area2D) -> void:
	var current_state = state_machine.current_state
	var target = area.get_parent()
	if target == self: return
	if current_state is PlayerAttackState or current_state is PlayerCrouchAttackState:
		var attack_state: PlayerAttackState = current_state
		HitEffects.play_hit_effect(attack_state.hit_strength)
		
		if target and target.has_method("take_damage"):
			# Get the attack box collision shape size for offset
			var shape = attack_box_collision_shape.shape
			var half_size := Vector2.ZERO
			if shape is CapsuleShape2D:
				half_size.x = shape.radius
				half_size.y = shape.height / 2.0
			elif shape is RectangleShape2D:
				half_size = shape.size / 2.0
			
			# Offset toward the target so the particle appears on their surface
			var dir = sign(target.global_position.x - global_position.x)
			var hit_position := attack_box.global_position + Vector2(half_size.x * dir, 0)
			
			target.take_damage(self, attack_state.hit_strength, attack_state.hit_type, hit_position)

## Called when player gets hit
func _on_hurtbox_hit(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if is_invincible or state_machine.current_state is PlayerHurtState:
		return
	
	var attacker = area.get_parent()
	if attacker == self:
		return
		
	if not attacker or not attacker.has_method("get_attack_damage"):
		return
	
	var hit_strength: HitEffects.HitStrength
	var hit_type: PlayerAttackState.HitType
	if attacker:
		hit_strength = attacker.get_hit_strength()
		hit_type = attacker.get_hit_type()
	
	# The attack box's global position is the hit location
	var hit_position: Vector2 = area.global_position 
	
	take_damage(attacker, hit_strength, hit_type, hit_position)

func get_hit_type():
	var attack_state: PlayerState = state_machine.current_state as PlayerAttackState
	return attack_state.hit_type

func get_hit_strength():
	var attack_state: PlayerState = state_machine.current_state as PlayerAttackState
	return attack_state.hit_strength

func get_attack_damage(hit_strength: HitEffects.HitStrength) -> float:
	match hit_strength:
		HitEffects.HitStrength.LIGHT: return 5
		HitEffects.HitStrength.MEDIUM: return 10
		HitEffects.HitStrength.HEAVY: return 15
		HitEffects.HitStrength.SUPER: return 25
	return 0.0

## Take damage and transition to hurt state
func take_damage(attacker: Fighter, hit_strength: HitEffects.HitStrength, hit_type: PlayerAttackState.HitType, hit_position: Vector2 = global_position) -> void:
	if is_invincible:
		return
	
	if (state_machine.current_state is PlayerParryState or 
	state_machine.current_state is PlayerCrouchParryState):
		current_health -= 0
		stamina = clampf(10 + stamina, 0, 100)
	else:
		current_health -= get_attack_damage(hit_strength)
	current_health = max(0, current_health)
	
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()
		return
	
	var hurt_state_name = "Hurt"
	if state_machine.current_state is PlayerCrouchState or input_crouch:
		hurt_state_name = "CrouchHurt"
	
	var hurt_state = state_machine.states.get(hurt_state_name)
	if hurt_state and hurt_state is PlayerHurtState:
		if state_machine.current_state is PlayerCrouchParryState and hit_type == PlayerAttackState.HitType.LOW:
			attacker.apply_knockback(self, hit_strength)
			parry_particle.global_position = hit_position
			parry_particle.restart()
			return
		elif state_machine.current_state is PlayerParryState and hit_type == PlayerAttackState.HitType.HIGH:
			attacker.apply_knockback(self, hit_strength)
			parry_particle.global_position = hit_position
			parry_particle.restart()
			state_machine.change_state(state_machine.states.get("Idle"))
			return
			
		hurt_state.attacker_position = attacker.global_position
		hurt_state.set_knockback_strength(hit_strength)
		state_machine.change_state(hurt_state)
		
func apply_knockback(from: Fighter, hit_strength: HitEffects.HitStrength) -> void:
	# Knock self away from 'from' (the defender)
	var knockback_dir: float = sign(global_position.x - from.global_position.x)
	
	var knockback_amount: float
	match hit_strength:
		HitEffects.HitStrength.LIGHT: knockback_amount = 30.0
		HitEffects.HitStrength.MEDIUM: knockback_amount = 60.0
		HitEffects.HitStrength.HEAVY: knockback_amount = 70.0
		HitEffects.HitStrength.SUPER: knockback_amount = 80.0
		_: knockback_amount = 80.0
	
	velocity = Vector2(knockback_dir * knockback_amount, -40)
	
## Handle death
func die() -> void:
	print(fighter_name + " " + str(player_number) + " has been defeated!")
	died.emit()
	queue_free()

## Set invincibility state
func set_invincible(invincible: bool) -> void:
	is_invincible = invincible
	
	if invincible:
		hurtbox_collision_shape.set_deferred("disabled", true)
	else:
		hurtbox_collision_shape.set_deferred("disabled", false)

## Heal the player
func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func use_stamina(amount: float) -> bool:
	if stamina < amount:
		return false
	stamina -= amount
	return true

func change_direction(dir: float):
	sprite_2d.scale.x = dir
	attack_pivot.scale.x = dir

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
