extends CharacterBody2D
class_name Fighter

signal health_changed(new_health: float, max_health: float)
signal died

@export var fighter_name: String = ""
@export var state_machine: StateMachine
@export var parry_particle: ParryParticle

@export_group("Stats")
@export var max_health: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_speed: float = 1.0
@export var max_stamina: int = 100
@export var stamina_gain: float = 10.0

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
@onready var combo_buffer: ComboBuffer = $ComboBuffer

var player_number: int = 0
var device_id: int = 0
var other_fighter: Fighter

var is_invincible: bool = false
var current_health: float = 100.0
var stamina := 100.0

var input_crouch := false
var input_parry := false
var input_jump := false
var input_up := false

func _ready() -> void:
	state_machine.init()
	
	# Auto-register all attack state sequences
	for state_name in state_machine.states:
		var state = state_machine.states[state_name]
		if state is PlayerAttackState and not state.sequence.is_empty():
			combo_buffer.register(state_name, state.sequence)
			
	animation_player.speed_scale = attack_speed
	current_health = max_health

	attack_box.area_entered.connect(_on_attack_hit)
	hurtbox_area.area_shape_entered.connect(_on_hurtbox_hit)

	health_changed.emit(current_health, max_health)
	ui_layer.show()

	if player_number == 2:
		ui_layer.scale.x = -1
		mug_shot.scale.x = -1
		ui_layer.offset.x = 320
		sprite_2d.scale.x = -1
		attack_pivot.scale.x = -1

func _on_attack_hit(area: Area2D) -> void:
	var current_state = state_machine.current_state
	var target = area.get_parent()
	if target == self:
		return
	if not (current_state is PlayerAttackState):
		return
	
	var attack_state: PlayerAttackState = current_state
	HitEffects.play_hit_effect(attack_state.hit_strength)

	if not target or not target.has_method("take_damage"):
		return

	var shape = attack_box_collision_shape.shape
	var half_size := Vector2.ZERO
	if shape is CapsuleShape2D:
		half_size.x = shape.radius
		half_size.y = shape.height / 2.0
	elif shape is RectangleShape2D:
		half_size = shape.size / 2.0

	var dir = sign(target.global_position.x - global_position.x)
	var hit_position := attack_box.global_position + Vector2(half_size.x * dir, 0)

	target.take_damage(self, attack_state.hit_strength, attack_state.up_strength, attack_state.hit_type, hit_position)

func _on_hurtbox_hit(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if is_invincible or state_machine.current_state is PlayerHurtState:
		return

	var attacker = area.get_parent()
	if attacker == self or not attacker or not attacker.has_method("get_attack_damage"):
		return

	take_damage(attacker, attacker.get_hit_strength(), attacker.get_up_strength(), attacker.get_hit_type(), area.global_position)

func get_hit_type() -> PlayerAttackState.HitType:
	var attack_state := state_machine.current_state as PlayerAttackState
	return attack_state.hit_type

func get_hit_strength() -> HitEffects.HitStrength:
	var attack_state := state_machine.current_state as PlayerAttackState
	return attack_state.hit_strength

func get_up_strength() -> HitEffects.HitStrength:
	var attack_state := state_machine.current_state as PlayerAttackState
	return attack_state.up_strength

func get_attack_damage(hit_strength: HitEffects.HitStrength) -> float:
	match hit_strength:
		HitEffects.HitStrength.LIGHT: return 5
		HitEffects.HitStrength.MEDIUM: return 10
		HitEffects.HitStrength.HEAVY: return 15
		HitEffects.HitStrength.SUPER: return 25
	return 0.0

func take_damage(attacker: Fighter,
	hit_strength: HitEffects.HitStrength,
	up_strength: HitEffects.HitStrength,
	hit_type: PlayerAttackState.HitType,
	hit_position: Vector2 = global_position) -> void:

	if is_invincible:
		return

	var is_parrying := (state_machine.current_state is PlayerParryState or
		state_machine.current_state is PlayerCrouchParryState)

	if is_parrying:
		stamina = clampf(stamina + 10, 0, max_stamina)
	else:
		current_health -= get_attack_damage(hit_strength)
	current_health = max(0, current_health)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()
		return

	# Handle parry knockback
	if state_machine.current_state is PlayerCrouchParryState and hit_type == PlayerAttackState.HitType.LOW:
		attacker.apply_knockback(self, hit_strength)
		parry_particle.global_position = hit_position
		parry_particle.restart()
		return
	elif state_machine.current_state is PlayerParryState and hit_type == PlayerAttackState.HitType.HIGH:
		attacker.apply_knockback(self, hit_strength)
		parry_particle.global_position = hit_position
		parry_particle.restart()
		return

	var hurt_state_name := "CrouchHurt" if (state_machine.current_state is PlayerCrouchState or input_crouch) else "Hurt"
	var hurt_state = state_machine.states.get(hurt_state_name)

	if hurt_state and hurt_state is PlayerHurtState:
		hurt_state.attacker_position = attacker.global_position
		hurt_state.set_knockback_strength(hit_strength, up_strength)
		state_machine.change_state(hurt_state)

func apply_knockback(from: Fighter, hit_strength: HitEffects.HitStrength) -> void:
	var knockback_dir : float = sign(global_position.x - from.global_position.x)
	var knockback_amount: float
	match hit_strength:
		HitEffects.HitStrength.LIGHT: knockback_amount = 30.0
		HitEffects.HitStrength.MEDIUM: knockback_amount = 60.0
		HitEffects.HitStrength.HEAVY: knockback_amount = 70.0
		_: knockback_amount = 80.0
	velocity = Vector2(knockback_dir * knockback_amount, -40)

func die() -> void:
	print(fighter_name + " " + str(player_number) + " has been defeated!")
	died.emit()
	queue_free()

func set_invincible(invincible: bool) -> void:
	is_invincible = invincible
	hurtbox_collision_shape.set_deferred("disabled", invincible)

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func use_stamina(amount: float) -> bool:
	if stamina < amount:
		return false
	stamina -= amount
	return true

func change_direction(dir: float) -> void:
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

	# Only log fresh presses, not releases
	for action in ["light_punch", "strong_punch", "light_kick", "strong_kick", "crouch", "jump", "left", "right"]:
		if event.is_action_pressed(action):
			combo_buffer.add_input(action)

	input_crouch = event.is_action_pressed("crouch")
	input_parry = event.is_action_pressed("parry")
	input_jump = event.is_action_pressed("jump")
	input_up = event.is_action_pressed("up")

	state_machine.process_input(event)
