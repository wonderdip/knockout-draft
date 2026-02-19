extends PlayerState
class_name PlayerAttackState

var light_punch_anim: String = "light_punch"
var strong_punch_anim: String = "strong_punch"
var uppercut_anim: String = "uppercut"
var crouch_light_punch_anim: String = "crouch_light_punch"
var crouch_strong_punch_anim: String = "crouch_strong_punch"
var jump_punch_anim: String = "jump_punch"

var kick_anim: String = "kick"
var high_kick_anim: String = "high_kick"
@export var hit_strength: HitEffects.HitStrength = HitEffects.HitStrength.LIGHT

var finished: bool = false

func enter() -> void:
	var cost = get_stamina_cost(hit_strength)
	if not player.use_stamina(cost):
		return # Cancel attack if not enough stamina
	finished = false
	
	if not player.animation_player.animation_finished.is_connected(_on_anim_finished):
		player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func exit() -> void:
	var attack_box_shape: CollisionShape2D = player.attack_box_collision_shape
	attack_box_shape.shape.height = 44
	attack_box_shape.disabled = true
	
func _on_anim_finished(_anim_name: StringName):
	finished = true

func get_stamina_cost(action: HitEffects.HitStrength) -> int:
	match action:
		HitEffects.HitStrength.LIGHT: return 5
		HitEffects.HitStrength.MEDIUM: return 10
		HitEffects.HitStrength.HEAVY: return 15
		HitEffects.HitStrength.SUPER: return 25
	return 0
