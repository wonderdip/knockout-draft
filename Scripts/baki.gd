extends Fighter

# Signal must be defined at the top!
signal health_changed(new_health: float, max_health: float)

func _ready() -> void:
	state_machine.init()
	animation_player.speed_scale = attack_speed
	current_health = max_health
		
	# Connect signals
	attack_box.area_entered.connect(_on_attack_hit)
	hurtbox_area.area_shape_entered.connect(_on_hurtbox_hit)
	
	# Emit initial health for UI
	health_changed.emit(current_health, max_health)
	
	if player_number == 2:
		ui_layer.scale.x = -1
		mug_shot.scale.x = -1
		ui_layer.offset.x = 384

## Called when player's attack connects with target
func _on_attack_hit(area: Area2D) -> void:
	var current_state = state_machine.current_state
	var target = area.get_parent()
	if target == self: return
	if current_state is PlayerAttackState:
		var attack_state = current_state as PlayerAttackState
		HitEffects.play_hit_effect(attack_state.hit_strength)
		
		# Apply damage to target if it has a take_damage method
		
		if target and target.has_method("take_damage"):
			target.take_damage(self, attack_state.hit_strength)

## Called when player gets hit
func _on_hurtbox_hit(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# Ignore if invincible or already in hurt state
	if is_invincible or state_machine.current_state is PlayerHurtState:
		return
	
	# Get the attacker
	var attacker = area.get_parent()
	if attacker == self:
		return
		
	if not attacker or not attacker.has_method("get_attack_damage"):
		return
	
	# Get attack strength if available
	var hit_strength = HitEffects.HitStrength.MEDIUM
	if attacker.has_method("get_hit_strength"):
		hit_strength = attacker.get_hit_strewngth()
		
	take_damage(attacker, hit_strength)

func get_attack_damage(hit_strength: HitEffects.HitStrength) -> float:
	match hit_strength:
		HitEffects.HitStrength.LIGHT: return 5
		HitEffects.HitStrength.MEDIUM: return 10
		HitEffects.HitStrength.HEAVY: return 15
		HitEffects.HitStrength.SUPER: return 25
	return 0.0

## Take damage and transition to hurt state
func take_damage(attacker: Variant, hit_strength: HitEffects.HitStrength) -> void:
	if is_invincible:
		return
	
	if (state_machine.current_state is PlayerParryState or 
	state_machine.current_state is PlayerCrouchParryState):
		current_health -= get_attack_damage(hit_strength) / 5
	else:
		current_health -= get_attack_damage(hit_strength)
	current_health = max(0, current_health)
	
	# Emit signal for UI updates
	health_changed.emit(current_health, max_health)
	
	# Check for death
	if current_health <= 0:
		die()
		return
	
	# Determine which hurt state to use
	var hurt_state_name = "Hurt"
	if state_machine.current_state is PlayerCrouchState or input_crouch:
		hurt_state_name = "CrouchHurt"
	
	
	var hurt_state = state_machine.states.get(hurt_state_name)
	if hurt_state and hurt_state is PlayerHurtState:
		if (state_machine.current_state is PlayerCrouchParryState 
		or state_machine.current_state is PlayerParryState):
			return
			
		# Store attacker position for knockback calculation
		hurt_state.attacker_position = attacker.global_position
		# Set knockback strength based on attack type
		hurt_state.set_knockback_strength(hit_strength)
		state_machine.change_state(hurt_state)

## Handle death
func die() -> void:
	print(fighter_name + " has been defeated!")
	# Transition to death/KO state or restart scene
	# You can implement this later
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
