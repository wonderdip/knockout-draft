extends PlayerState
class_name PlayerHurtState

## State for when player takes damage
## Handles hitstun, knockback, and invincibility frames

@export var light_hitstun: float = 0.2
@export var medium_hitstun: float = 0.35
@export var heavy_hitstun: float = 0.5

@export var light_knockback: float = 80.0
@export var medium_knockback: float = 120.0
@export var heavy_knockback: float = 200.0

@export var light_up: float = 50.0
@export var medium_up: float = 100.0
@export var heavy_up: float = 180.0

@export var invincibility_duration: float = 0.6

var hurt_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_up: float = 50.0
var knockback_x_amount: float = 0.0
var is_invincible: bool = false
var attacker_position: Vector2 = Vector2.ZERO

var hurt_animation: String = "hurt"

func enter() -> void:
	super()
	hurt_timer = medium_hitstun
	is_invincible = true
	
	player.velocity = Vector2.ZERO
	player.animation_player.call_deferred("play", hurt_animation)
	
	apply_knockback()
	start_invincibility()
	
func exit() -> void:
	super()
	knockback_velocity = Vector2.ZERO

func get_next_state() -> State:
	if player.is_on_floor():
		return get_state("Idle")
	else:
		return get_state("Fall")

func process_physics(delta: float) -> State:
	hurt_timer -= delta
	
	player.velocity.x = lerp(player.velocity.x, 0.0, 5.0 * delta)
	
	if not player.is_on_floor():
		player.velocity.y += gravity * delta
	elif hurt_timer <= 0:
		player.velocity.y = 0
	
	player.move_and_slide()
	
	if hurt_timer <= 0:
		return get_next_state()
	
	return null

func apply_knockback() -> void:
	if (state_machine.previous_state == get_state("Parry") or 
	state_machine.previous_state == get_state("CrouchParry")):
		player.velocity = calculate_knockback() / 5
	else:
		player.velocity = calculate_knockback()
		print(calculate_knockback())
		
func calculate_knockback() -> Vector2:
	var knockback_dir: float
	
	if attacker_position != Vector2.ZERO:
		knockback_dir = sign(player.global_position.x - attacker_position.x)
	else:
		knockback_dir = -1
	
	return Vector2(knockback_dir * knockback_x_amount, -knockback_up)

## Maps a HitStrength enum value to its knockback X amount
func strength_to_knockback(strength: HitEffects.HitStrength) -> float:
	match strength:
		HitEffects.HitStrength.LIGHT: return light_knockback
		HitEffects.HitStrength.MEDIUM: return medium_knockback
		HitEffects.HitStrength.HEAVY, HitEffects.HitStrength.SUPER: return heavy_knockback
	return medium_knockback

## Maps a HitStrength enum value to its knockback Y (up) amount	
func strength_to_up(strength: HitEffects.HitStrength) -> float:
	match strength:
		HitEffects.HitStrength.LIGHT: return light_up
		HitEffects.HitStrength.MEDIUM: return medium_up
		HitEffects.HitStrength.HEAVY, HitEffects.HitStrength.SUPER: return heavy_up
	return medium_up

## Set knockback and hitstun based on hit_strength (x) and up_strength (y)
func set_knockback_strength(hit: HitEffects.HitStrength, up: HitEffects.HitStrength) -> void:
	match hit:
		HitEffects.HitStrength.LIGHT:
			hurt_timer = light_hitstun
		HitEffects.HitStrength.MEDIUM:
			hurt_timer = medium_hitstun
		HitEffects.HitStrength.HEAVY, HitEffects.HitStrength.SUPER:
			hurt_timer = heavy_hitstun
		_:
			hurt_timer = medium_hitstun
	
	knockback_x_amount = strength_to_knockback(hit)
	knockback_up = strength_to_up(up)

## Start invincibility frames with visual feedback
func start_invincibility() -> void:
	is_invincible = true
	player.set_invincible(true)
	
	var sprite = player.sprite_2d
	var tween = create_tween()
	var flash_count = int(invincibility_duration / 0.1)
	tween.set_loops(flash_count)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.05)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)
	
	get_tree().create_timer(invincibility_duration, false).timeout.connect(_end_invincibility)

func _end_invincibility() -> void:
	is_invincible = false
	player.set_invincible(false)
	player.sprite_2d.modulate.a = 1.0
