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

@export var invincibility_duration: float = 0.6

var hurt_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var is_invincible: bool = false
var attacker_position: Vector2 = Vector2.ZERO

var hurt_animation: String = "hurt"

func enter() -> void:
	super()
	hurt_timer = medium_hitstun
	
	is_invincible = true
	
	# Cancel any current velocity
	player.velocity = Vector2.ZERO
	player.animation_player.play(hurt_animation)
	
	# Apply knockback
	apply_knockback()
	
	# Start invincibility frames
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
	# Count down hitstun
	hurt_timer -= delta
	
	# Apply knockback with smooth decay
	player.velocity.x = lerp(player.velocity.x, 0.0, 5.0 * delta)
	
	# Apply gravity if in air
	if not player.is_on_floor():
		player.velocity.y += gravity * delta
	else:
		# On ground, reduce vertical velocity
		player.velocity.y = 0
	
	player.move_and_slide()
	
	# Check if hitstun is over
	if hurt_timer <= 0:
		return get_next_state()
	
	return null

## Apply knockback based on attacker position
func apply_knockback() -> void:
	# Determine knockback direction
	var knockback_dir: float
	
	if attacker_position != Vector2.ZERO:
		# Knock away from attacker
		knockback_dir = sign(player.global_position.x - attacker_position.x)
	else:
		# Default to opposite of facing direction
		knockback_dir = -1
	
	# Apply knockback
	var knockback_x = knockback_dir * medium_knockback
	var knockback_y = -50.0  # Small upward component
	
	player.velocity = Vector2(knockback_x, knockback_y)

## Set knockback strength based on attack type
func set_knockback_strength(strength: HitEffects.HitStrength) -> void:
	var kb_amount: float
	
	match strength:
		HitEffects.HitStrength.LIGHT:
			hurt_timer = light_hitstun
			kb_amount = light_knockback
		HitEffects.HitStrength.MEDIUM:
			hurt_timer = medium_hitstun
			kb_amount = medium_knockback
		HitEffects.HitStrength.HEAVY, HitEffects.HitStrength.SUPER:
			hurt_timer = heavy_hitstun
			kb_amount = heavy_knockback
		_:
			kb_amount = medium_knockback
	
	# Update knockback velocity with new strength
	if player.velocity.x != 0:
		var dir = sign(player.velocity.x)
		player.velocity.x = dir * kb_amount

## Start invincibility frames with visual feedback
func start_invincibility() -> void:
	is_invincible = true
	player.set_invincible(true)
	
	# Create flashing effect
	var sprite = player.sprite_2d
	var tween = create_tween()
	var flash_count = int(invincibility_duration / 0.1)
	tween.set_loops(flash_count)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.05)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)
	
	# End invincibility after duration
	get_tree().create_timer(invincibility_duration, false).timeout.connect(_end_invincibility)

func _end_invincibility() -> void:
	is_invincible = false
	player.set_invincible(false)
	player.sprite_2d.modulate.a = 1.0
