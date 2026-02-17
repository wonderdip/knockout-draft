extends TextureProgressBar
class_name StaminaBar



@export var player: Player

func _ready() -> void:
	max_value = player.max_stamina
	value = player.max_stamina

func _process(_delta: float) -> void:
	if not player:
		return
	value = player.stamina
	
