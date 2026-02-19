extends CharacterBody2D
class_name Fighter

@export var fighter_name: String = ""
@export var camera: CamShake

@export_group("Stats")
@export var max_health: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_speed: float = 1.0
@export var max_stamina: int = 100
@export var stamina_gain: float = 10.0  # Stamina per second
