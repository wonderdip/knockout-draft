extends PlayerState
class_name PlayerAttackState

var light_punch_anim: String = "light_punch"
var strong_punch_anim: String = "strong_punch"
var forward_light_punch_anim: String = "forward_light_punch"
var jump_punch_anim: String = "jump_punch"
var kick_anim: String = "kick"
var high_kick_anim: String = "high_kick"

var special_one_anim: String = "double_gut_punch"
var special_two_anim: String = "mach_punch"

@export var hit_strength: HitEffects.HitStrength = HitEffects.HitStrength.LIGHT
@export var up_strength: HitEffects.HitStrength = HitEffects.HitStrength.LIGHT
@export var hit_type: HitType
@export var knock_down: bool
@export var sequence: Array[String]

enum HitType {HIGH, LOW, GRAB}

var finished: bool = false
var air_speed: float = 75.0

func enter() -> void:
	var cost = get_stamina_cost(hit_strength)
	if not player.use_stamina(cost):
		return # Cancel attack if not enough stamina
	finished = false
	player.z_index = 10
	
	if not player.animation_player.animation_finished.is_connected(_on_anim_finished):
		player.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func exit() -> void:
	var attack_box_shape: CollisionShape2D = player.attack_box_collision_shape
	attack_box_shape.shape.height = 44
	attack_box_shape.set_deferred("disabled", true)
	player.z_index = 1
	
func _on_anim_finished(_anim_name: StringName):
	finished = true

func get_stamina_cost(action: HitEffects.HitStrength) -> int:
	match action:
		HitEffects.HitStrength.LIGHT: return 5
		HitEffects.HitStrength.MEDIUM: return 10
		HitEffects.HitStrength.HEAVY: return 15
		HitEffects.HitStrength.SUPER: return 25
	return 0
